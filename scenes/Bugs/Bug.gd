extends CharacterBody3D

@export var health: int = 50

@onready var splat_sound: AudioStreamPlayer3D = $SplatSound
@onready var anim: AnimationPlayer = $AnimationPlayer

func hit(_from: Vector3, damage: int) -> void:
	if health <= 0:
		splat_sound.play()
		return
	health -= damage
	anim.play("Die")
	get_tree().create_timer(10.0).timeout.connect(queue_free)
