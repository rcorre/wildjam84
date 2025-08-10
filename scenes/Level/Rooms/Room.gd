class_name Room extends Node3D

signal on_room_breach(room_id, direction)

@export var walls : Array[PackedScene]

@export var furniture_sets : Array[PackedScene]

var wall_offsets = {
	Constants.DIRECTION.NORTH: Vector4(6, 0, 0, PI / 2),
	Constants.DIRECTION.SOUTH: Vector4(-6, 0, 0, PI / 2),
	Constants.DIRECTION.EAST: Vector4(0, 0, 6, 0),
	Constants.DIRECTION.WEST: Vector4(0, 0, -6, 0),
}

var id : int
var room_offset : Vector3
var build_north : bool
var build_east : bool
var build_south : bool
var build_west : bool

func _coin_flip() -> bool:
	return randi_range(0, 1) == 1

func _create_random_wall() -> BreakableCollection:
	var index := randi_range(0, walls.size() - 1)
	var wall := walls[index].instantiate() as BreakableCollection
	return wall

func _build_that_wall(direction: String) -> void:
	var offset := wall_offsets[direction] as Vector4
	var position_offset := Vector3(offset.x, offset.y, offset.z)
	var rotation_offset := offset.w

	var wall := _create_random_wall()
	wall.name = direction
	wall.on_wall_break.connect(_on_wall_break)

	self.add_child(wall)

	wall.translate(position_offset)
	wall.rotate(Vector3.UP, rotation_offset)
	if (_coin_flip()):
		wall.rotate(position_offset.normalized(), PI)

func _ready() -> void:
	assert(walls.size() > 0)

	self.translate(self.room_offset)
	self.name = "room%d" % id

	if build_north:
		_build_that_wall(Constants.DIRECTION.NORTH)
	if build_east:
		_build_that_wall(Constants.DIRECTION.EAST)
	if build_south:
		_build_that_wall(Constants.DIRECTION.SOUTH)
	if build_west:
		_build_that_wall(Constants.DIRECTION.WEST)

func _on_wall_break(broken_wall_name: String) -> void:
	on_room_breach.emit(id, broken_wall_name)

func with_args(
	room_id: int,
	position_offset: Vector3,
  build_north_wall := true,
  build_east_wall := true,
  build_south_wall := true,
  build_west_wall := true
) -> Room:
	# todo: difficulty level or something, room can take over bug generation
	self.id = room_id
	self.room_offset = position_offset
	self.build_north = build_north_wall
	self.build_east = build_east_wall
	self.build_south = build_south_wall
	self.build_west = build_west_wall
	return self
