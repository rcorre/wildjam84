extends Button

func _pressed() -> void:
	get_tree().change_scene_to_file("res://menus/title/Title.tscn")
	Engine.time_scale = 1.0 # this was slowed down when defeating the final boss
