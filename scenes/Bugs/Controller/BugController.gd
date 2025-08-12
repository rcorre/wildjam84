class_name BugController extends Node3D

const DIFFICULTY_LEVELS = [
	{
		# It's assumed that the chances will always total to 100
		"bugs": [
			{
				"name": "Spider",
				"chance": 100,
			},
		],
		"min_spawn_frequency": 5.0,
		"max_spawn_frequency": 10.0,
		"max_concurrent_bugs": 2,
	},
	# {
	# 	"bugs": [
	# 		{
	# 			"name": "Spider",
	# 			"chance": 100,
	# 		},
	# 	],
	# 	"min_spawn_frequency": 3.0,
	# 	"max_spawn_frequency": 7.0,
	# 	"max_concurrent_bugs": 6,
	# },
	# # todo: get more bug models
	# {
	# 	"bugs": [
	# 		{
	# 			"name": "Spider",
	# 			"chance": 50,
	# 		},
	# 		{
	# 			"name": "Spider",
	# 			"chance": 50,
	# 		},
	# 	],
	# 	"min_spawn_frequency": 3.0,
	# 	"max_spawn_frequency": 7.0,
	# 	"max_concurrent_bugs": 5,
	# },
]

const ROOM_SIDES = {
	1: Constants.DIRECTION.NORTH,
	2: Constants.DIRECTION.EAST,
	3: Constants.DIRECTION.WEST,
	4: Constants.DIRECTION.SOUTH,
	5: Constants.DIRECTION.UP,
	6: Constants.DIRECTION.DOWN
}

@export var Spider : PackedScene

var difficulty_level: int
var bugs : Array[Bug] = []

func _ready() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(spawn.bind(timer))
	spawn(timer)

func _on_bug_death(bug: Bug) -> void:
	var index := bugs.find(bug)
	bugs.remove_at(index)
	get_tree().create_timer(3.0).timeout.connect(bug.queue_free)

func _get_bug_scene(bug_name: String) -> PackedScene:
	match bug_name:
		"Spider": return Spider
		_: return Spider

func _pick_bug(options: Array) -> PackedScene:
	var rand_val := randi_range(1, 100)
	for option in options:
		rand_val -= option.chance
		if rand_val <= 0:
			return _get_bug_scene(option.name as String)
	return _get_bug_scene("")

func _place_on_bounds(bug: Bug, x_bounds: Vector2, y_bounds: Vector2, z_bounds: Vector2) -> void:
	var final_x : float = INF
	var final_y : float = INF
	var final_z : float = INF

	# pick which surface of the room the bug will spawn on
	var side := ROOM_SIDES[randi_range(1, 6)] as String
	match side:
		Constants.DIRECTION.NORTH: 
			final_x = x_bounds.y
			bug.rotation_degrees = Vector3(90, 0, 90)
		Constants.DIRECTION.SOUTH:
			final_x = x_bounds.x
			# I think I was gimbal locking or something idunno
			bug.rotation_degrees = Vector3(90, 180, 0)
			bug.rotate(Vector3.UP, -PI / 2)
		Constants.DIRECTION.EAST:
			final_z = z_bounds.y
			bug.rotation_degrees = Vector3(90, 180, 0)
		Constants.DIRECTION.WEST:
			final_z = z_bounds.x
			bug.rotation_degrees = Vector3(90, 0, 0)
		Constants.DIRECTION.UP:
			final_y = y_bounds.y
			bug.rotation_degrees = Vector3(180, 0, 0)
		Constants.DIRECTION.DOWN:
			final_y = y_bounds.x
			bug.rotation_degrees = Vector3(0, 0, 0)
	
	if final_x == INF:
		final_x = randf_range(x_bounds.x, x_bounds.y)
	if final_y == INF:
		final_y = randf_range(y_bounds.x, y_bounds.y)
	if final_z == INF:
		final_z = randf_range(z_bounds.x, z_bounds.y)
	
	bug.position = Vector3(final_x, final_y, final_z)

func spawn(timer: Timer) -> void:
	var config : Dictionary = DIFFICULTY_LEVELS[difficulty_level]
	timer.start(randf_range(config.min_spawn_frequency as float, config.max_spawn_frequency as float))
	
	if bugs.size() >= config.max_concurrent_bugs:
		return
	
	var next_bug := _pick_bug(config.bugs).instantiate() as Bug
	bugs.append(next_bug)
	next_bug.on_bug_death.connect(_on_bug_death)
	
	add_child(next_bug)
	_place_on_bounds(
		next_bug,
		Vector2(-5.75, 5.75),
		Vector2(-2.75, 2.75),
		Vector2(-5.75, 5.75),
	)

func with_args(
	level: int,
) -> BugController:
	difficulty_level = clamp(level, 0, DIFFICULTY_LEVELS.size() - 1)
	return self
