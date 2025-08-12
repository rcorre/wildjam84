class_name Throwable extends RigidBody3D

# const DAMAGE_MULTIPLIER := 8.0
const DAMAGE_MULTIPLIER := 8.0
const HELD_ITEM_MATERIAL := preload("res://assets/materials/HeldItemMaterial.tres")

# This determines the sounds and effects used for impacts
# Always add new items to the end, or it screws up godot exports
enum ItemMaterial {
	Wood,
	Glass
}

enum ItemSize {
	Tiny,
	Small,
	Medium,
	Large,
	VeryLarge,
}

const HIT_SOUNDS := {
	ItemMaterial.Wood: preload("res://assets/sounds/wood_hit.wav"),
	ItemMaterial.Glass: preload("res://assets/sounds/glass_hit.wav"),
}

@export var item_material: ItemMaterial
@export var item_size : ItemSize

var hit_player: AudioStreamPlayer3D
var hit_count := 0.0

func _ready() -> void:
	body_entered.connect(self._on_body_entered)
	sleeping_state_changed.connect(_on_sleep)
	max_contacts_reported = 4

	# set mass based on size
	self.mass = _get_mass()

	# Add a stream player for impact noises based on the material
	# Use a randomizer so sounds aren't too repetitive
	hit_player = AudioStreamPlayer3D.new()
	add_child(hit_player)
	var stream := AudioStreamRandomizer.new()
	hit_player.stream = stream
	stream.random_pitch = 1.2
	stream.random_volume_offset_db = 5.0
	stream.add_stream(0, HIT_SOUNDS[item_material] as AudioStream)

	# Generate collider encompassing the total aabb
	# Using rect for now to make it stable, convex was unstable
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var aabb := AABB()
	for c in get_children():
		var mi := c as MeshInstance3D
		if mi:
			aabb = aabb.merge(mi.get_aabb())
	box.size = aabb.size
	col.position = aabb.position + box.size / 2.0
	col.shape = box
	add_child(col)

func _on_sleep():
	if sleeping:
		# Object has come to rest, no longer need accurate collisions
		continuous_cd = false
		contact_monitor = false

func _get_mass():
	match item_size:
		ItemSize.Tiny: return 5
		ItemSize.Small: return 10
		ItemSize.Medium: return 25
		ItemSize.Large: return 50
		ItemSize.VeryLarge: return 100
	return 1

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
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)

func throw(force: Vector3) -> void:
	prints("throwing", self)
	self.hit_count = 0
	self.freeze = false
	self.apply_central_impulse(force)
	_override_material(null)
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)

	# Detect collisions more accurately when thrown
	continuous_cd = true
	contact_monitor = true

func drop() -> void:
	prints("dropping", self)
	self.freeze = false
	_override_material(null)
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)

func _on_body_entered(body: Node) -> void:
	hit_count += 1
	hit_player.play()

	if body.has_method("hit"):
		var damage := linear_velocity.length() * mass * DAMAGE_MULTIPLIER * (1 / hit_count)
		prints(self, "hit", body, "for", damage)
		body.call("hit", self.position, damage)
