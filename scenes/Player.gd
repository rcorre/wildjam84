extends CharacterBody3D

const GRAVITY := 9.8
const ACCEL := 3.0
const DECEL := 6.0
const SPEED := 6.0
const JUMP_SPEED := 5.0
const MOUSE_SENSITIVITY := Vector2(0.0015, 0.0020)

# How quickly the held object snaps to your hands
const GRAB_SNAP := 8.0

const THROW_FORCE := 10.0

@onready var camera: Camera3D = $Camera3D
@onready var grab_ray: RayCast3D = $Camera3D/RayCast3D
@onready var grab_point: Node3D = $Camera3D/GrabPoint

var look: Vector2
var held_object: Throwable

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(ev: InputEvent):
	var mouse := ev as InputEventMouseMotion
	if mouse:
		look -= mouse.relative * MOUSE_SENSITIVITY
		look.x = wrapf(look.x, -PI, PI)
		look.y = clamp(look.y, -PI / 3.0, PI / 3.0)

func interact() -> void:
	if held_object:
		return throw()
	grab()

func grab() -> void:
	assert(not held_object, "Cannot grab if holding")
	var col := grab_ray.get_collider() as Throwable
	if not col:
		return
	prints("grabbed", col)
	held_object = col

	# this disables rigid physics so we can move the object like it's kinematic
	held_object.freeze = true

func throw() -> void:
	assert(held_object, "Cannot throw if not holding")
	prints("throwing", held_object)
	held_object.freeze = false
	held_object.apply_central_impulse(-camera.global_transform.basis.z * THROW_FORCE)
	held_object = null

func _physics_process(delta: float) -> void:
	rotation.y = look.x
	camera.rotation.x = look.y

	if Input.is_action_just_pressed("grab"):
		interact()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED

	var move := Input.get_vector("right", "left", "backward", "forward").rotated(-look.x)
	var accel := DECEL if move.is_equal_approx(Vector2.ZERO) else ACCEL
	velocity.x = lerp(velocity.x, move.x * SPEED, accel * delta)
	velocity.y -= GRAVITY * delta
	velocity.z = lerp(velocity.z, move.y * SPEED, accel * delta)
	move_and_slide()

	if held_object:
		# move object toward your hands
		held_object.global_transform = held_object.global_transform.interpolate_with(grab_point.global_transform, delta * GRAB_SNAP)
