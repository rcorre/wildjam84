extends Node3D

func _ready() -> void:
	for c in get_children():
		var mi := c as MeshInstance3D
		if mi:
			mi.create_convex_collision(true, true)

