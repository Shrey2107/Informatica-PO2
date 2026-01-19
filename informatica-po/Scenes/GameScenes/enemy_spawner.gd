extends Node3D

@onready var Spawn_timer = $SpawnTimer

const enemy = preload("res://Scenes/GameScenes/enemy.tscn")



func _on_spawn_timer_timeout():
	var new_enemy = enemy.instantiate()
	
	get_parent().add_child(new_enemy)
	
	
	new_enemy.global_position = global_position
