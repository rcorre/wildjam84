extends CharacterBody3D

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

var current_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(move.bind(timer))
	move(timer)

func _physics_process(_delta: float) -> void:
	if health <= 0:
		return

	move_and_slide()

func move(timer: Timer) -> void:
	if health <= 0:
		return
	timer.start(randf_range(min_move_secs, max_move_secs))
	if randf() < move_chance:
		rotate_object_local(Vector3.UP, randf_range(0, PI * 2))
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
		get_tree().create_timer(3.0).timeout.connect(queue_free)
		splat_sound.play()
		splat_particles.emitting = true
		collision_layer = 0
		collision_mask = 0
		mesh.visible = false
