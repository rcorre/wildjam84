extends CharacterBody3D
class_name Bug

# Chance to enter slomo on killing a bug
const SLOMO_CHANCE := 0.2

# Time you can stand near a bug till it jumps on you
const JUMP_SECS := 3.0

# How fast the jump animation is
const JUMP_ANIM_SECS := 0.25

signal on_bug_death(bug: Bug)

@onready var visibility_notifier: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

@export var health := 50
@export var speed := 2.0

# time between movements
@export var min_move_secs := 0.0
@export var max_move_secs := 2.0

# chance to move vs standing still
@export var move_chance := 0.5

@onready var mesh: Node3D = $Armature/Skeleton3D/Mesh

@onready var walk_sound: AudioStreamPlayer3D = $WalkSound
@onready var splat_sound: AudioStreamPlayer3D = $SplatSound
@onready var splat_particles: CPUParticles3D = $SplatParticles
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var jump_area: Area3D = $JumpArea

var current_direction: Vector3 = Vector3.ZERO
var jump_charge := 0.0
var face_hugging: Player

var player : Player
var chase_factor : float = 0

var last_floor_normal := Vector3.ZERO
var last_turn := -1.0

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(move.bind(timer))
	move(timer)

	# 3 is "enemy", no easy way to get this programatically
	set_collision_layer_value(3, true)

func _physics_process(delta: float) -> void:
	if health <= 0:
		return

	if face_hugging == null and jump_area.has_overlapping_bodies():
		maybe_jump(delta)
	else:
		jump_charge = move_toward(jump_charge, 0.0, delta)

	if last_turn != -1:
		last_turn += delta

	if not face_hugging:
		var collision := move_and_collide(basis.z * delta * speed)
		if collision and (last_turn == -1 or last_turn > 2):
			last_turn = 0
			basis = Basis.looking_at(collision.get_normal(0).cross(up_direction), collision.get_normal(0))
		# move_and_slide()

func maybe_jump(delta: float) -> void:
	var player := jump_area.get_overlapping_bodies()[0] as Player
	if player.face_hugger:
		# already got one
		return

	jump_charge = move_toward(jump_charge, 1.0, delta / JUMP_SECS)

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
	tween.tween_property(self, "position", Vector3.FORWARD * 0.5, JUMP_ANIM_SECS)
	tween.tween_property(self, "rotation", Vector3(PI / -2.0, 0.0, 0.0), JUMP_ANIM_SECS)

	# just don't collide while jumping
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(3, true)

func _get_move_rotation() -> float:
	if player:
		# seems to work when I tested with one spider but it's hard to notice much difference in the chaos of many
		var angle_to_player := basis.z.signed_angle_to(Basis.looking_at(player.position, up_direction).z, up_direction) + PI
		return (randf_range(0, PI * 2) + (chase_factor * angle_to_player)) / (chase_factor + 1)
	return randf_range(0, PI * 2)

func move(timer: Timer) -> void:
	if health <= 0:
		return
	timer.start(randf_range(min_move_secs, max_move_secs))
	if randf() < move_chance:
		rotate_object_local(up_direction, _get_move_rotation())
		velocity = speed * basis.z
		anim.play("Walk")
		walk_sound.playing = true
	else:
		velocity = Vector3.ZERO
		anim.play("Idle")
		walk_sound.playing = false

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
