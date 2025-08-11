class_name Breakable extends RigidBody3D

@export_group("Animation")
## How many seconds until the shards fade away.
@export_range(0.0, 30.0) var fade_delay := 2.0
## How many seconds until the shards shrink.
@export_range(0.0, 30.0) var shrink_delay := 2.0
## How long the animation lasts before the shard is removed.
@export_range(0.0, 30.0) var animation_length := 3.0

var health := 100.0

func _notify_collection_of_break() -> void:
	# this should be a signal but I was finding it cumbersome to accomplish what I'm trying to do
	var parent = self.get_parent()
	while parent and not is_instance_of(parent, BreakableCollection):
		parent = parent.get_parent()
	if parent: 
		(parent as BreakableCollection).on_break()

func _break(impulse: Vector3) -> void:
	self._notify_collection_of_break()
	var tween := get_tree().create_tween()
	tween.set_parallel(true)

	# animate fade and shrink
	var mesh: MeshInstance3D
	for child in get_children():
		if child is MeshInstance3D:
			mesh = child
			break
	if mesh:
		var material = mesh.get_active_material(0)
		if material is StandardMaterial3D:
			var modified: StandardMaterial3D = material.duplicate()
			modified.flags_transparent = true
			tween.tween_property(modified,
					"albedo_color", Color(1, 1, 1, 0), animation_length - fade_delay)\
				.set_delay(fade_delay)\
				.set_trans(Tween.TRANS_EXPO)\
				.set_ease(Tween.EASE_OUT)
			mesh.material_override = modified

		self.freeze = false
		# todo: figure out how to make this less floaty
		impulse.y = clamp(impulse.y, -INF, 1)
		self.apply_impulse(impulse)

		if shrink_delay >= 0:
			tween.tween_property(mesh, "scale", Vector3.ZERO, animation_length)\
					.set_delay(shrink_delay)

	# destroy object
	tween.tween_callback(self.queue_free).set_delay(animation_length)

func hit(from: Vector3, damage: int) -> void:
	if health <= 0:
		return

	# todo: add some kind of visual cracking effect for damage, also general textures
	health -= min(99, damage)

	if health <= 0:
		# complete nonsense force calculation
		self._break(from * lerpf(0.5, 2.0, damage / 100.0))

func set_color(material: StandardMaterial3D) -> void:
	($WallFragmentMesh as MeshInstance3D).set_surface_override_material(0, material)
