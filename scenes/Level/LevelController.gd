class_name LevelController extends Node3D

const ROOM_OFFSET := 12

@export var room : PackedScene
@export var player : Player

var level_map : LevelMap
var map_size := (Constants.DIFFICULTY_LEVELS.size() * 2) - 1
var center : int = map_size / 2
var room_count := 0

func _create_room_node(
	id: int,
	position_offset: Vector3,
	build_north: bool,
	build_east: bool,
	build_south: bool,
	build_west: bool
) -> Room:
	
	var new_room := (self.room.instantiate() as Room).with_args(
		id,
		position_offset,
		player,
		build_north,
		build_east,
		build_south,
		build_west,
		level_map.distance_from_center_by_id(id),
	)
	self.add_child(new_room)
	new_room.translate(Vector3.UP * 3)
	new_room.on_room_breach.connect(_on_room_breached)
	return new_room

func _create_room(x: int, z: int):
	if not level_map.can_exist(x, z) or level_map.exists(x, z):
		return

	var position_offset := Vector3((x - center) * ROOM_OFFSET, 0, (z - center) * ROOM_OFFSET)
	var build_north := not level_map.has_north_neighbor(x, z)
	var build_east := not level_map.has_east_neighbor(x, z)
	var build_south := not level_map.has_south_neighbor(x, z)
	var build_west := not level_map.has_west_neighbor(x, z)

	room_count += 1
	var id := room_count
	level_map.add(x, z, id)

	_create_room_node(
		id,
		position_offset,
		build_north,
		build_east,
		build_south,
		build_west,
	)

func _on_room_breached(room_id: int, direction: String):
	var room_location := level_map.get_coordinates(room_id)
	var x := room_location.x
	var z := room_location.y
	if direction == Constants.DIRECTION.NORTH:
		x += 1
	if direction == Constants.DIRECTION.SOUTH:
		x -= 1
	if direction == Constants.DIRECTION.EAST:
		z += 1
	if direction == Constants.DIRECTION.WEST:
		z -= 1
	_create_room(x, z)

func _ready() -> void:
	level_map = LevelMap.new().init(map_size)
	_create_room(center, center)


class LevelMap:
	# +x is north
	# +z is east
	var map : Array[Array]
	var id_to_map : Dictionary
	var size : int

	func init(map_size: int) -> LevelMap:
		self.size = map_size
		map = []
		id_to_map = {}
		for x in range(self.size):
			map.append([])
			for z in range(self.size):
				map[x].append(0)
		return self
	
	func distance_from_center(from_x: int, from_z: int) -> int:
		var center := size / 2
		return max(abs(from_x - center), abs(from_z - center))

	func distance_from_center_by_id(from_id: int) -> int:
		var from := id_to_map[from_id] as Vector2i
		return distance_from_center(from.x, from.y)

	func add(x: int, z: int, id: int) -> void:
		map[x][z] = id
		id_to_map[id] = Vector2i(x, z)
	
	func get_coordinates(id: int) -> Vector2i:
		return id_to_map[id]
	
	func exists(x: int, z: int) -> bool:
		return map[x][z] != 0
	
	func can_exist(x: int, z: int) -> bool:
		return z >= 0 and z < size and x >= 0 and x < size

	func has_north_neighbor(x: int, z: int) -> bool:
		return x < self.size - 1 && map[x + 1][z] != 0
	
	func has_south_neighbor(x: int, z: int) -> bool:
		return x > 0 && map[x - 1][z] != 0

	func has_east_neighbor(x: int, z: int) -> bool:
		return z < self.size - 1 && map[x][z + 1] != 0
	
	func has_west_neighbor(x: int, z: int) -> bool:
		return z > 0 && map[x][z - 1] != 0
