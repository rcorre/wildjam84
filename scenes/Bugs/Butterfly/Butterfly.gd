class_name Butterfly extends Bug

const ALL_DIRECTIONS = [
	Vector3.MODEL_BOTTOM,
	Vector3.MODEL_FRONT,
	Vector3.MODEL_LEFT,
	Vector3.MODEL_REAR,
	Vector3.MODEL_RIGHT,
	Vector3.MODEL_TOP,
]

func _physics_process(delta: float) -> void:
	if health <= 0:
		return
	move_and_slide()

func _on_ready() -> void:
	self.move_animation_name = "fly"
	self.idle_animation_name = "fly"
	self.mesh = $"butterfly_root/Skeleton3D/butterfly "

func _get_move_rotation(axis: Vector3) -> float:
	if player:
		var angle_to_player := basis.z.signed_angle_to(Basis.looking_at(player.position, axis).z, axis) + PI
		return (randf_range(0, PI * 2) + (chase_factor * angle_to_player)) / (chase_factor + 1)
	return randf_range(0, PI * 2)

func _rotate_for_move() -> void:
	var axis := ALL_DIRECTIONS[randi_range(0, 5)] as Vector3
	rotate_object_local(axis, _get_move_rotation(axis))
