extends CanvasLayer

signal upgrade_selected(upgrade_name)

# Upgrade pool using only your original upgrades
var upgrade_pool = [
	"battery efficiency +5%",
	"battery spawnrate +10%",
	"sprint speed +10%",
	"walk speed +10%",
	"spawnspeed enemies -5%",
	"enemy speed -5%",
]

# Node references
@onready var button1 = $CenterContainer/Control/VBoxContainer/Button1
@onready var button2 = $CenterContainer/Control/VBoxContainer/Button2
@onready var button3 = $CenterContainer/Control/VBoxContainer/Button3
func _ready():
	# Pause the game and allow UI interaction
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

	# Connect buttons
	button1.pressed.connect(_on_button_pressed.bind(button1))
	button2.pressed.connect(_on_button_pressed.bind(button2))
	button3.pressed.connect(_on_button_pressed.bind(button3))

	# Generate 3 random upgrades
	generate_upgrades()


func generate_upgrades():
	var choices = upgrade_pool.duplicate()
	choices.shuffle()
	var selected = choices.slice(0, 3)

	button1.text = selected[0]
	button1.set_meta("upgrade", selected[0])

	button2.text = selected[1]
	button2.set_meta("upgrade", selected[1])

	button3.text = selected[2]
	button3.set_meta("upgrade", selected[2])


func _on_button_pressed(button):
	var upgrade = button.get_meta("upgrade")
	apply_upgrade(upgrade)


func apply_upgrade(type):
	match type:
		"battery efficiency +5%":
			Global.batt_eff += 0.05
		"battery spawnrate +10%":
			Global.batt_spawn_mult -= 0.1
		"sprint speed +10%":
			Global.speed_sprint += 0.1
		"walk speed +10%":
			Global.speed_walk += 0.1
		"spawnspeed enemies -5%":
			Global.spawnrate_enemies += 0.05
		"enemy speed -5%":
			Global.enemy_speed -= 0.05

	# Close menu and resume game
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
