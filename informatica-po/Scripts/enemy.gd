extends CharacterBody3D

const  speed := 3.0

@onready var nav_agent = $NavigationAgent3D


var player: Node3D




var offset = Vector3(
	randf_range(-1, 1),
	0,
	randf_range(-1, 1)
)




func _ready():
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if not player:
		return

	nav_agent.target_position = player.global_position + offset
	var next_point = nav_agent.get_next_path_position()
	var desired_velocity = (next_point - global_position).normalized() * speed

	nav_agent.velocity = desired_velocity
	velocity = nav_agent.get_velocity()

	move_and_slide()


func die():
	queue_free()
