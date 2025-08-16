extends AudioStreamPlayer

const BOSS_MUSIC := preload("res://assets/sounds/music/ShootTheGap.ogg")
const NORMAL_MUSIC := preload("res://assets/sounds/music/Flies.ogg")

func _ready() -> void:
	Constants.boss_area_entered.connect(_on_boss_area_entered)
	Constants.on_try_again.emit(_on_try_again)

func _on_boss_area_entered():
	stream = BOSS_MUSIC
	play()

func _on_try_again(_player):
	stream = NORMAL_MUSIC
	play()

