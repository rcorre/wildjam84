extends Control

@onready var player: Player

@onready var throw_power_bar: ProgressBar = $ThrowPowerBar
@onready var tunnel_vision: Control = $TunnelVision
@onready var game_over: Control = $GameOver

func _ready() -> void:
	player = get_parent()
	assert(player, "HUD cannot find player")

func _process(delta: float) -> void:
	throw_power_bar.value = player.throw_charge
	tunnel_vision.modulate.a = player.panic
	if player.panic >= 1.0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_over.visible = true
		game_over.modulate.a = move_toward(game_over.modulate.a, 1.0, delta)
