extends Control

@onready var player: Player

@onready var throw_power_bar: ProgressBar = $ThrowPowerBar
@onready var tunnel_vision: Control = $TunnelVision

func _ready() -> void:
	player = get_parent()
	assert(player, "HUD cannot find player")

func _process(_delta: float) -> void:
	throw_power_bar.value = player.throw_charge
	tunnel_vision.modulate.a = player.panic
