class_name BreakableCollection extends Node3D

var collection: Array

func _ready() -> void:
	collection = []

func register(member: Breakable) -> void:
	# todo: figure out if this is doable
	# the motivation for this is having a parent node that tracks a graph
	# of its children and destroys wall pieces that are no longer supported
	# ie it no longer connects to another node or the edge of the wall
	# 
	# not sure how this might be computed at runtime... don't really want to
	# manually define these in the editor.
	# especially because I added 3 other breakable models so we can have variety later
	# 
	# could probably push this off for later, or just scrap the whole idea
	if not collection.has(member):
		collection.append(member)
