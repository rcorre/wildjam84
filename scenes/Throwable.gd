class_name Throwable extends RigidBody3D

const DAMAGE_MULTIPLIER := 8.0
const HELD_ITEM_MATERIAL := preload("res://assets/materials/HeldItemMaterial.tres")

@onready var hit_sound: AudioStreamPlayer3D = $HitSound

var is_throwing := false

func _ready() -> void:
	body_entered.connect(self._on_body_entered)
	sleeping_state_changed.connect(_on_sleep)
	max_contacts_reported = 4

func _on_sleep():
	if sleeping:
		# Object has come to rest, no longer need accurate collisions
		continuous_cd = false
		contact_monitor = false

func _override_material(mat: StandardMaterial3D):
	# give it a partially transparent material so we can see through it while holding
	for c in get_children():
		var mesh := c as MeshInstance3D
		if mesh:
			mesh.material_override = mat

func grab() -> void:
	# this disables rigid physics so we can move the object like it's kinematic
	freeze = true
	_override_material(HELD_ITEM_MATERIAL)

func throw(force: Vector3) -> void:
	prints("throwing", self)
	is_throwing = true
	self.freeze = false
	self.apply_central_impulse(force)
	_override_material(null)

	# Detect collisions more accurately when thrown
	continuous_cd = true
	contact_monitor = true

func _on_body_entered(body: Node) -> void:
	# don't break stuff on bounces
	if not is_throwing:
		return
	is_throwing = false

	hit_sound.play()

	if body.has_method("hit"):
		var damage := linear_velocity.length() * mass * DAMAGE_MULTIPLIER
		prints(self, "hit", body, "for", damage)
		body.call("hit", self.position, damage)
