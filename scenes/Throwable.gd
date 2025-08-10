class_name Throwable extends RigidBody3D

const DAMAGE_MULTIPLIER := 8.0
const HELD_ITEM_MATERIAL := preload("res://assets/materials/HeldItemMaterial.tres")

# This determines the sounds and effects used for impacts
# Always add new items to the end, or it screws up godot exports
enum ItemMaterial {
	Wood,
	Glass
}

const HIT_SOUNDS := {
	ItemMaterial.Wood: preload("res://assets/sounds/wood_hit.wav"),
	ItemMaterial.Glass: preload("res://assets/sounds/glass_hit.wav"),
}

@export var item_material: ItemMaterial

var hit_player: AudioStreamPlayer3D

var is_throwing := false

func _ready() -> void:
	body_entered.connect(self._on_body_entered)
	sleeping_state_changed.connect(_on_sleep)
	max_contacts_reported = 4

	# Add a stream player for impact noises based on the material
	# Use a randomizer so sounds aren't too repetitive
	hit_player = AudioStreamPlayer3D.new()
	add_child(hit_player)
	var stream := AudioStreamRandomizer.new()
	hit_player.stream = stream
	stream.random_pitch = 1.2
	stream.random_volume_offset_db = 5.0
	stream.add_stream(0, HIT_SOUNDS[item_material] as AudioStream)

	# I don't want to manually create a scene from each of the Kenney GLBs
	# Instead, create a collider programatically
	# all the kenney furniture assets have a mesh child named something(Clone)
	var mi = find_child("*(Clone)") as MeshInstance3D
	if not mi:
		push_error("No mesh mi found in ", self)
		print_tree_pretty()
		return

	# Could try create_multiple_convex_collisions if we want more precise shapes
	var col := CollisionShape3D.new()
	col.shape = mi.mesh.create_convex_shape()
	add_child(col)

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

func drop() -> void:
	prints("dropping", self)
	is_throwing = false
	self.freeze = false
	_override_material(null)

func _on_body_entered(body: Node) -> void:
	# don't break stuff on bounces
	if not is_throwing:
		return
	is_throwing = false

	hit_player.play()

	if body.has_method("hit"):
		var damage := linear_velocity.length() * mass * DAMAGE_MULTIPLIER
		prints(self, "hit", body, "for", damage)
		body.call("hit", self.position, damage)
