extends Node
var level = Global.level
const base_level:int = 100
const level_multiplier:float = 1.25


func get_xp_needed(level:int) -> int:
	return int(base_level * pow(level_multiplier, level))


func _physics_process(delta):

	while Global.xp >= get_xp_needed(level):
		Global.xp -= get_xp_needed(level)
		level_up()




func level_up():
	Global.level += 1
	var level = Global.level
	print("Level Up! Now level ", Global.level)
	show_upgrade_screen()


func show_upgrade_screen():
	var screen = preload("res://Scenes/UI-scenes/UpgradeScreen.tscn").instantiate()
	get_tree().current_scene.add_child(screen)
