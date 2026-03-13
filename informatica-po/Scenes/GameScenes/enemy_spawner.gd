extends Node3D

@onready var Spawn_timer = $SpawnTimer

const enemy = preload("res://Scenes/GameScenes/enemy.tscn")



func _on_spawn_timer_timeout():
	var new_enemy = enemy.instantiate()
	var time = 5 * pow(0.5, (Global.score / 2000.0))*Global.spawnrate_enemies
	time = clamp(time, 0.3, 5.0)
	Spawn_timer.wait_time = time
	Spawn_timer.start()
	print(Spawn_timer.wait_time)
	get_parent().add_child(new_enemy)
	
	
	new_enemy.global_position = global_position
