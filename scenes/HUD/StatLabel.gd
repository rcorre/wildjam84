extends Label

@export var stat: Constants.Stat

func _ready() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	player.level_up_completed.connect(update_text)
	update_text()

func update_text() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	text = "%d / 3" % player.get_stat(stat)
