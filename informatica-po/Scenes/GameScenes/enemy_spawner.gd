extends Node3D

const ENEMY_SCENE = preload("res://Scenes/GameScenes/enemy.tscn")
const ACTIVE_DISTANCE = 50.0
const MIN_INTERVAL = 2.5  # seconds
const MAX_INTERVAL = 10.0  # seconds

var spawn_timer := 0.0
var player: Node3D

func _ready():
	# Get player node (adjust path if needed)
	player = get_tree().get_root().get_node("world/player")

func _process(delta):
	if not player:
		return

	# Only spawn if player is within ACTIVE_DISTANCE
	var distance = global_position.distance_to(player.global_position)
	if distance > ACTIVE_DISTANCE:
		return

	# Update timer
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_enemy()

		# Calculate next spawn time based on score
		# Assuming Global.score exists
		var time = MAX_INTERVAL * pow(0.5, Global.score / 2000.0)
		time = clamp(time, MIN_INTERVAL, MAX_INTERVAL)
		spawn_timer = time

func spawn_enemy():
	var enemy_instance = ENEMY_SCENE.instantiate()
	get_parent().add_child(enemy_instance)
	enemy_instance.global_position = global_position
