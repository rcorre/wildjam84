extends AudioStreamPlayer

const BOSS_MUSIC := preload("res://assets/sounds/music/ShootTheGap.ogg")

func _ready() -> void:
	Constants.boss_area_entered.connect(_on_boss_area_entered)

func _on_boss_area_entered():
	stream = BOSS_MUSIC
	play()

