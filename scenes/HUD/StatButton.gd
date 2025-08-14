extends Button

@export var stat: Constants.Stat

func _ready() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	disabled = player.get_stat(stat) > 2

func _pressed() -> void:
	print("level presset")
	disabled = true
	var player: Player = get_tree().get_first_node_in_group("player")
	player.level_stat(stat)
