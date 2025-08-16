extends Node

@warning_ignore_start("unused_signal")

signal on_try_again(new_player: Player)
signal game_won
signal boss_area_entered

enum Stat {
	Strength,
	Courage,
	Telekinesis,
}

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
				"name": "Ant",
				"chance": 100,
			},
		],
		"min_spawn_frequency": 6.0,
		"max_spawn_frequency": 12.0,
		"max_concurrent_bugs": 2,
		"chase_factor": 0,
		"wall_color": Color.WEB_GREEN,
	},
	{
		"bugs": [
			{
				"name": "Ant",
				"chance": 50,
			},
			{
				"name": "Ladybug",
				"chance": 50,
			},
		],
		"min_spawn_frequency": 5.0,
		"max_spawn_frequency": 11.0,
		"max_concurrent_bugs": 4,
		"chase_factor": 1,
		"wall_color": Color.PALE_GREEN,
	},
	{
		"bugs": [
			{
				"name": "Ant",
				"chance": 10,
			},
			{
				"name": "Ladybug",
				"chance": 30,
			},
			{
				"name": "Butterfly",
				"chance": 60,
			},
		],
		"min_spawn_frequency": 5.0,
		"max_spawn_frequency": 10.0,
		"max_concurrent_bugs": 5,
		"chase_factor": 3,
		"wall_color": Color.GOLD,
	},
		{
		"bugs": [
			{
				"name": "Ant",
				"chance": 5,
			},
			{
				"name": "Ladybug",
				"chance": 10,
			},
			{
				"name": "Butterfly",
				"chance": 25,
			},
			{
				"name": "Spider",
				"chance": 60,
			},
		],
		"min_spawn_frequency": 4.0,
		"max_spawn_frequency": 8.0,
		"max_concurrent_bugs": 6,
		"chase_factor": 5,
		"wall_color": Color.DARK_ORANGE,
	},
		{
		"bugs": [
			{
				"name": "Ladybug",
				"chance": 5,
			},
			{
				"name": "Butterfly",
				"chance": 10,
			},
			{
				"name": "Spider",
				"chance": 85,
			},
		],
		"min_spawn_frequency": 4.0,
		"max_spawn_frequency": 7.0,
		"max_concurrent_bugs": 6,
		"chase_factor": 10,
		"wall_color": Color.WEB_MAROON,
	},
]
