extends CharacterBody3D

var player = null

const speed = 4.5

@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D

func _ready() -> void:
	player = get_node(player_path)

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
