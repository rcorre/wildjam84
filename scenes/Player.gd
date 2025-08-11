extends CharacterBody3D
class_name Player

const GRAVITY := 9.8
const ACCEL := 3.0
const DECEL := 6.0
const SPEED := 6.0
const JUMP_SPEED := 5.0
const MOUSE_SENSITIVITY := Vector2(0.0015, 0.0020)

# Panic reduction per second
const PANIC_RECOVERY_RATE := 0.1

# Panic gain per second
const PANIC_RATE := 0.15

# How quickly the held object snaps to your hands
const GRAB_SNAP := 8.0

# Amount of shaking required to throw off bug
const SHAKE_REQUIRED := 40.0

const MAX_THROW_FORCE := 500.0
const MAX_THROW_SECS := 2.0

@onready var camera: Camera3D = $Camera3D
@onready var grab_ray: RayCast3D = $Camera3D/RayCast3D
@onready var grab_point: Node3D = $Camera3D/GrabPoint
@onready var bug_detector: Area3D = $BugDetector
# I'm sorry
@onready var bug_detector_radius: float = (
	(
		bug_detector.get_node("CollisionShape3D") as CollisionShape3D
	).shape as SphereShape3D
).radius
@onready var panic_sound: AudioStreamPlayer3D = $PanicSound

var look: Vector2
var held_object: Throwable
var throw_charge := 0.0

# 0..1, game over at 1
var panic: float
var face_hugger: Bug

# at 1, successfully shook off bug
var shake := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _unhandled_input(ev: InputEvent):
	var mouse := ev as InputEventMouseMotion
	if mouse:
		var motion := mouse.relative * MOUSE_SENSITIVITY
		look -= motion
		look.x = wrapf(look.x, -PI, PI)
		look.y = clamp(look.y, -PI / 2.0, PI / 2.0)
		if face_hugger:
			shake += motion.length() / SHAKE_REQUIRED

func grab() -> void:
	assert(not held_object, "Cannot grab if holding")
	var col := grab_ray.get_collider() as Throwable
	if not col:
		return
	prints("grabbed", col)
	held_object = col
	held_object.grab()

func throw() -> void:
	assert(held_object, "Cannot throw if not holding")
	var force: float = lerp(0.0, MAX_THROW_FORCE, throw_charge)
	prints("throwing", held_object, "with force", force)
	held_object.throw(-camera.global_transform.basis.z * force)
	held_object = null
	throw_charge = 0

func drop() -> void:
	if not held_object:
		return
	prints("dropping", held_object)
	held_object.drop()
	held_object = null
	throw_charge = 0

func _physics_process(delta: float) -> void:
	if panic >= 1.0:
		# "fall" backwards
		rotation.x = move_toward(rotation.x, -PI / 2.0, delta * 2.0)
		return

	rotation.y = look.x
	camera.rotation.x = look.y

	if not held_object and Input.is_action_just_released("grab"):
		grab()
	elif held_object and Input.is_action_pressed("drop"):
		drop()
	elif held_object and Input.is_action_pressed("grab"):
		throw_charge = min(
			1.0,
			throw_charge + lerpf((delta / MAX_THROW_SECS) / 8, (delta / MAX_THROW_SECS) * 2, 1 - throw_charge),
		)
	elif held_object and Input.is_action_just_released("grab") and throw_charge > 0.0:
		throw()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED

	var move := Input.get_vector("right", "left", "backward", "forward").rotated(-look.x)
	var accel := DECEL if move.is_equal_approx(Vector2.ZERO) else ACCEL
	velocity.x = lerp(velocity.x, move.x * SPEED, accel * delta)
	velocity.y -= GRAVITY * delta
	velocity.z = lerp(velocity.z, move.y * SPEED, accel * delta)
	move_and_slide()

	if held_object:
		# jiggle the object as we charge up a throw
		var point := grab_point.global_transform
		point.origin.z += sin(Time.get_ticks_msec() / 20.0) * throw_charge * 0.5
		point.origin.x += cos(Time.get_ticks_msec() / 20.0) * throw_charge * 0.5

		# move object toward your hands
		held_object.global_transform = held_object.global_transform.interpolate_with(point, delta * GRAB_SNAP)

	if face_hugger:
		if shake >= 1.0:
			prints("Shook off", face_hugger)
			face_hugger.hit(global_position, 1000)
			face_hugger = null
			shake = 0.0
		else:
			var rate := delta * PANIC_RATE * 1.25
			_apply_panic(rate)
	else:
		apply_panic(delta)

func _apply_panic(rate: float, target : float = 1.0) -> void:
	panic = move_toward(panic, target, rate)
	panic_sound.volume_db = lerp(-80.0, 20.0, panic)

func apply_panic(delta: float) -> void:
	var visible_bugs: Array[Node3D]
	for body in bug_detector.get_overlapping_bodies():
		var bug := body as Bug
		if not bug:
			push_warning("non bug in bug area: ", body)
			continue
		if bug.visibility_notifier.is_on_screen():
			visible_bugs.push_back(bug)

	if visible_bugs.size() == 0:
		# panic = move_toward(panic, 0.0, delta * PANIC_RECOVERY_RATE)
		_apply_panic(delta * PANIC_RECOVERY_RATE, 0.0)
		return

	# more panic the closer you are to the bug
	var closest_distance := INF
	for bug in visible_bugs:
		closest_distance = min((bug.position - self.position).length(), closest_distance)
	var proximity_factor := lerpf(0.5, 2, 1 - (closest_distance / bug_detector_radius))

	# Use sqrt, so two bugs is more panic, but not twice as much
	var quantity_factor := sqrt(visible_bugs.size())

	var rate := delta * PANIC_RATE * proximity_factor * quantity_factor
	_apply_panic(rate)
