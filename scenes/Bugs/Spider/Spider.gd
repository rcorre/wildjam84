class_name Spider extends Bug

# Time you can stand near a bug till it jumps on you
const JUMP_SECS := 3.0

# How fast the jump animation is
const JUMP_ANIM_SECS := 0.25

@onready var jump_area: Area3D = $JumpArea

var current_direction: Vector3 = Vector3.ZERO
var jump_charge := 0.0
var face_hugging: Player

func _on_ready() -> void:
	self.move_animation_name = "Walk"
	self.idle_animation_name = "Idle"
	self.mesh = $Armature/Skeleton3D/Mesh

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

func _get_move_rotation() -> float:
	if player:
		# seems to work when I tested with one bug but it's hard to notice much difference in the chaos of many
		var angle_to_player := basis.z.signed_angle_to(Basis.looking_at(player.position, up_direction).z, up_direction) + PI
		return (randf_range(0, PI * 2) + (chase_factor * angle_to_player)) / (chase_factor + 1)
	return randf_range(0, PI * 2)

func _rotate_for_move() -> void:
	rotate_object_local(up_direction, _get_move_rotation())

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
