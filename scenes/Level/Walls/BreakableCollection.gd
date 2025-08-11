class_name BreakableCollection extends Node3D

signal on_wall_break(name)

#todo: break unconnected chunks?

func on_break() -> void:
	on_wall_break.emit(self.name)

func set_wall_color(material: StandardMaterial3D) -> void:
	var children := get_children()
	for child in children:
		(child as Breakable).set_color(material)
