class_name Spider extends Bug

var current_direction: Vector3 = Vector3.ZERO
var last_floor_normal := Vector3.ZERO
var last_turn := -1.0

func _on_ready() -> void:
	self.move_animation_name = "Walk"
	self.idle_animation_name = "Idle"
	self.mesh = $Armature/Skeleton3D/Mesh

func _on_physics_process(delta: float) -> void:
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
