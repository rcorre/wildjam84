extends Node

const DIRECTION = {
	"NORTH": "NORTH",
	"EAST": "EAST",
	"WEST": "WEST",
	"SOUTH": "SOUTH",
	"UP": "UP",
	"DOWN": "DOWN",
}

const DIFFICULTY_LEVELS = [
	{
		# It's assumed that the chances will always total to 100
		"bugs": [
			{
				"name": "Spider",
				"chance": 100,
			},
		],
		"min_spawn_frequency": 10.0,
		"max_spawn_frequency": 15.0,
		"max_concurrent_bugs": 2,
		"chase_factor": 0,
		"wall_color": Color.WEB_GREEN,
	},
	{
		"bugs": [
			{
				"name": "Spider",
				"chance": 100,
			},
		],
		"min_spawn_frequency": 7.0,
		"max_spawn_frequency": 12.0,
		"max_concurrent_bugs": 3,
		"chase_factor": 1,
		"wall_color": Color.PALE_GREEN,
	},
	{
		"bugs": [
			{
				"name": "Spider",
				"chance": 100,
			},
		],
		"min_spawn_frequency": 6.0,
		"max_spawn_frequency": 10.0,
		"max_concurrent_bugs": 4,
		"chase_factor": 3,
		"wall_color": Color.GOLD,
	},
		{
		"bugs": [
			{
				"name": "Spider",
				"chance": 100,
			},
		],
		"min_spawn_frequency": 6.0,
		"max_spawn_frequency": 8.0,
		"max_concurrent_bugs": 5,
		"chase_factor": 8,
		"wall_color": Color.DARK_ORANGE,
	},
		{
		"bugs": [
			{
				"name": "Spider",
				"chance": 100,
			},
		],
		"min_spawn_frequency": 5.0,
		"max_spawn_frequency": 7.0,
		"max_concurrent_bugs": 6,
		"chase_factor": 15,
		"wall_color": Color.WEB_MAROON,
	},
]
