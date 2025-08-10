extends Button


func _pressed() -> void:
	# Delete current player, add a new one
	# This assumes the player should start at 0,0
	var player := get_tree().get_nodes_in_group("player")[0]
	player.queue_free()
	var player_scene := load("res://scenes/Player.tscn") as PackedScene
	get_tree().current_scene.add_child(player_scene.instantiate())
