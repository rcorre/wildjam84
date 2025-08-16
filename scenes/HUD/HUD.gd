extends Control

@onready var player: Player

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var tunnel_vision: Control = $TunnelVision
@onready var game_over: Control = $GameOver
@onready var game_won: Control = $GameWon
@onready var shake_warning: Control = $ShakeWarning
@onready var level_up_panel: Control = $LevelUpPanel

var crosshair_radius := 1.0

func _ready() -> void:
	player = get_parent()
	player.leveled_up.connect(_on_level_up)
	player.level_up_completed.connect(_on_level_up_completed)
	assert(player, "HUD cannot find player")
	Constants.game_won.connect(_on_game_won)

func _on_game_won() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().create_tween().tween_property(game_won, "modulate:a", 1.0, 1.0)
	game_won.visible = true

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

	shake_warning.visible = player.face_hugger != null and not game_over.visible

func _draw() -> void:
	var center := size / 2.0
	draw_circle(center, crosshair_radius, Color.WHITE, false, 2.0, true)

	var charge: float = max(player.throw_charge, player.shake)
	draw_arc(center, 16.0, 0, 2 * PI * charge, 128, Color.GREEN.lerp(Color.RED, charge), 4.0, true)

func _on_level_up() -> void:
	anim.play("level_up")
	await anim.animation_finished
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_level_up_completed() -> void:
	anim.play_backwards("level_up")
	await anim.animation_finished
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# we entered slowmo when the level up started, exit it
	# note: the 0.1 delay actually equals 1s because we reduced the time scale
	var tween := get_tree().create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.2).set_delay(0.05)
