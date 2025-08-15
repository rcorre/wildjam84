extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("_apply_panic"):
		body.call("_apply_panic", 0.9)
		queue_free()
