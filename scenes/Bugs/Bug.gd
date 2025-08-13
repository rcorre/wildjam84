extends CharacterBody3D
class_name Bug

# Chance to enter slomo on killing a bug
const SLOMO_CHANCE := 0.2

signal on_bug_death(bug: Bug)

@onready var visibility_notifier: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

@export var health := 50
@export var speed := 2.0

# time between movements
@export var min_move_secs := 0.0
@export var max_move_secs := 2.0

# chance to move vs standing still
@export var move_chance := 0.5


@onready var walk_sound: AudioStreamPlayer3D = $WalkSound
@onready var splat_sound: AudioStreamPlayer3D = $SplatSound
@onready var splat_particles: CPUParticles3D = $SplatParticles
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var jump_area: Area3D = $JumpArea

var player : Player
var chase_factor : float = 0

var jump_charge := 0.0
var face_hugging: Player

# child classes must set
var mesh: Node3D
var move_animation_name : String
var idle_animation_name : String
var jump_secs : float
var jump_anim_secs : float

func _on_ready() -> void:
	pass

func _ready() -> void:
	_on_ready()
	Constants.on_try_again.connect(_on_try_again)
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(move.bind(timer))
	move(timer)

	# 3 is "enemy", no easy way to get this programatically
	set_collision_layer_value(3, true)

func _on_try_again(new_player: Player) -> void:
	self.player = new_player

func _on_physics_process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if health <= 0:
		return

	if face_hugging == null and jump_area.has_overlapping_bodies():
		maybe_jump(delta)
	else:
		jump_charge = move_toward(jump_charge, 0.0, delta)

	_on_physics_process(delta)

func _rotate_for_move() -> void:
	pass

func move(timer: Timer) -> void:
	if health <= 0:
		return
	timer.start(randf_range(min_move_secs, max_move_secs))
	if randf() < move_chance:
		_rotate_for_move()
		velocity = speed * basis.z
		anim.play(move_animation_name)
		walk_sound.playing = true
	else:
		velocity = Vector3.ZERO
		anim.play(idle_animation_name)
		walk_sound.playing = false

func maybe_jump(delta: float) -> void:
	var player := jump_area.get_overlapping_bodies()[0] as Player
	if player.face_hugger:
		# already got one
		return

	jump_charge = move_toward(jump_charge, 1.0, delta / jump_secs)

	if jump_charge < 1.0:
		return

	prints(self, "jumping on player")

	player.drop()

	# reparent to the player camera
	face_hugging = player
	face_hugging.face_hugger = self
	reparent(face_hugging.camera)
	var tween := get_tree().create_tween()

	# move our position to the camera, but a little forward
	tween.set_parallel()
	tween.tween_property(self, "position", Vector3.FORWARD * 0.5, jump_anim_secs)
	tween.tween_property(self, "rotation", Vector3(PI / -2.0, 0.0, 0.0), jump_anim_secs)

	# just don't collide while jumping
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(3, true)

func hit(_from: Vector3, damage: int) -> void:
	if health <= 0:
		return
	health -= damage
	if health <= 0:
		on_bug_death.emit(self)
		splat_sound.play()
		splat_particles.emitting = true
		collision_layer = 0
		collision_mask = 0
		mesh.visible = false
		if randf() <= SLOMO_CHANCE:
			# todo slowmo sound effect
			Engine.time_scale = 0.1
			var tween := get_tree().create_tween()
			# note: the 0.1 delay actually equals 1s because we reduced the time scale
			tween.tween_property(Engine, "time_scale", 1.0, 0.5).set_delay(0.1)

func with_args(
	player_ref: Player,
	chase_factor: float,
) -> Bug:
	self.player = player_ref
	self.chase_factor = chase_factor
	return self
