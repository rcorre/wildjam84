class_name Throwable extends RigidBody3D

var is_throwing := false

func _ready() -> void:
	body_entered.connect(self._on_body_entered)

func throw(force: Vector3) -> void:
	prints("throwing", self)
	is_throwing = true
	self.freeze = false
	self.apply_central_impulse(force)

func _on_body_entered(body: Node) -> void:
	# don't break stuff on bounces
	if not is_throwing:
		return
	is_throwing = false

	prints("collided with something", body)
	if body.has_method("hit"):
		# todo: base damage on throwable object weight
		body.call("hit", self.position, 50)
