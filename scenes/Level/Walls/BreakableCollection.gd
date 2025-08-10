class_name BreakableCollection extends Node3D

signal on_wall_break(name)

#todo: break unconnected chunks?

func on_break() -> void:
	on_wall_break.emit(self.name)
