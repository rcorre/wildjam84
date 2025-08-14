extends CharacterBody3D
class_name BossSpider

@export var health := 50
@export var speed := 2.0

# time between movements
@export var min_move_secs := 1.0
@export var max_move_secs := 4.0

# chance to move vs standing still
@export var move_chance := 0.7

@onready var mesh: Node3D = $Armature/Skeleton3D/Mesh

@onready var walk_sound: AudioStreamPlayer3D = $WalkSound
@onready var splat_sound: AudioStreamPlayer3D = $SplatSound
@onready var splat_particles: CPUParticles3D = $SplatParticles
@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var player: Node3D = get_tree().get_first_node_in_group("player")

var current_direction: Vector3 = Vector3.ZERO
var jump_charge := 0.0
var face_hugging: Player

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(move.bind(timer))
	move(timer)

	# 3 is "enemy", no easy way to get this programatically
	set_collision_layer_value(3, true)

func _physics_process(_delta: float) -> void:
	if health <= 0:
		return

	look_at(player.global_position, Vector3.UP, true)
	move_and_slide()

func move(_timer: Timer) -> void:
	if health <= 0:
		return
	if randf() < move_chance:
		velocity = speed * basis.z.rotated(Vector3.UP, randf_range(0, PI * 2))
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
		get_tree().create_timer(3.0).timeout.connect(queue_free)
		splat_sound.play()
		splat_particles.emitting = true
		collision_layer = 0
		collision_mask = 0
		mesh.visible = false
		Engine.time_scale = 0.1
		var tween := get_tree().create_tween()
		# note: the 0.1 delay actually equals 1s because we reduced the time scale
		tween.tween_property(Engine, "time_scale", 1.0, 1.0).set_delay(0.2)
