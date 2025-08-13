extends Button


func _pressed() -> void:
	# Delete current player, add a new one
	# This assumes the player should start at 0,0
	var player := get_tree().get_nodes_in_group("player")[0]
	player.queue_free()
	var player_scene := load("res://scenes/Player.tscn") as PackedScene
	var new_player := player_scene.instantiate() as Player
	get_tree().current_scene.add_child(new_player)
	Constants.on_try_again.emit(new_player)
