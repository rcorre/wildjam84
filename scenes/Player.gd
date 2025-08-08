extends CharacterBody3D

const GRAVITY := 9.8
const ACCEL := 3.0
const DECEL := 6.0
const SPEED := 6.0
const JUMP_SPEED := 5.0
const MOUSE_SENSITIVITY := Vector2(0.0015, 0.0020)

@onready var camera: Camera3D = $Camera3D

var look: Vector2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(ev: InputEvent):
	var mouse := ev as InputEventMouseMotion
	if mouse:
		look -= mouse.relative * MOUSE_SENSITIVITY
		look.x = wrapf(look.x, -PI, PI)
		look.y = clamp(look.y, -PI / 3.0, PI / 3.0)
	elif ev.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED

func _physics_process(delta: float) -> void:
	rotation.y = look.x
	camera.rotation.x = look.y

	var move := Input.get_vector("right", "left", "backward", "forward").rotated(-look.x)
	var accel := DECEL if move.is_equal_approx(Vector2.ZERO) else ACCEL
	velocity.x = lerp(velocity.x, move.x * SPEED, accel * delta)
	velocity.y -= GRAVITY * delta
	velocity.z = lerp(velocity.z, move.y * SPEED, accel * delta)
	move_and_slide()
