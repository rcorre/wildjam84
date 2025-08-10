class_name BreakableCollection extends Node3D

signal on_wall_break(name)

# var collection: Array

# func _ready() -> void:
# 	collection = []

# func register(member: Breakable) -> void:
# 	# todo: figure out if this is doable
# 	# the motivation for this is having a parent node that tracks a graph
# 	# of its children and destroys wall pieces that are no longer supported
# 	# ie it no longer connects to another node or the edge of the wall
# 	# 
# 	# not sure how this might be computed at runtime... don't really want to
# 	# manually define these in the editor.
# 	# especially because I added 3 other breakable models so we can have variety later
# 	# 
# 	# could probably push this off for later, or just scrap the whole idea
# 	if not collection.has(member):
# 		collection.append(member)

# func _notify_room_of_break() -> void:
# 	# this should be a signal but I was finding it cumbersome to accomplish what I'm trying to do
# 	var parent = self.get_parent()
# 	while parent and not is_instance_of(parent, Room):
# 		parent = parent.get_parent()
# 	if parent: 
# 		(parent as Room).on_wall_break(self.name)

func on_break() -> void:
	# _notify_room_of_break()
	on_wall_break.emit(self.name)
