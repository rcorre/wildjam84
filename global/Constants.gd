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
