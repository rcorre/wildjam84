extends Button

@export var stat: Constants.Stat

func _ready() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	disabled = player.get_stat(stat) > 2

func _pressed() -> void:
	disabled = true
	get_tree().create_timer(1.0).timeout.connect(set_disabled.bind(false))
	var player: Player = get_tree().get_first_node_in_group("player")
	player.level_stat(stat)
