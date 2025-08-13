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

var player : Player
var chase_factor : float = 0

var last_floor_normal := Vector3.ZERO
var last_turn := -1.0

# child classes must set
var mesh: Node3D
var move_animation_name : String
var idle_animation_name : String

func _on_ready() -> void:
	pass

func _ready() -> void:
	_on_ready()
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(move.bind(timer))
	move(timer)

	# 3 is "enemy", no easy way to get this programatically
	set_collision_layer_value(3, true)

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
