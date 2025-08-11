extends Control

@onready var player: Player

@onready var tunnel_vision: Control = $TunnelVision
@onready var game_over: Control = $GameOver

var crosshair_radius := 1.0

func _ready() -> void:
	player = get_parent()
	assert(player, "HUD cannot find player")

func _process(delta: float) -> void:
	tunnel_vision.modulate.a = player.panic
	if player.panic >= 1.0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if player.held_object:
			player.drop()
		game_over.visible = true
		game_over.modulate.a = move_toward(game_over.modulate.a, 1.0, delta)

	# expand the crosshair if we can grab an object
	var target_radius := 1.0
	if player.grab_ray.is_colliding() and not player.held_object:
		target_radius = 8.0
	crosshair_radius = lerp(crosshair_radius, target_radius, delta * 12.0)
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	draw_circle(center, crosshair_radius, Color.WHITE, false, 2.0, true)
	draw_arc(center, 16.0, 0, 2 * PI * player.throw_charge, 128, Color.GREEN.lerp(Color.RED, player.throw_charge), 4.0, true)
