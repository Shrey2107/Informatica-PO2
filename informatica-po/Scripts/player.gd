extends CharacterBody3D

#speler nodes
@onready var head = $head
@onready var standing_colision_shape = $standing_colision_shape
@onready var crouching_colision_shape = $crouching_colision_shape
@onready var ray_cast_3d = $RayCast3D

#snelheden
var current_speed = 5.0
const crouch_speed = 3.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const  jump_velocity = 4.5



#input variablen
var direction = Vector3.ZERO
const mouse_sensitivty = 0.4



var crouching_depth = -0.5

var lerp_speed = 10.0

func _ready():
	#zorgt ervoor dat het muis in het spel blijft
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		#draait het speeler en als je de muis beweegt
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivty))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivty))
		#geeft een maximale rotatie 
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))


func _physics_process(delta: float) -> void:
	
	
	#bewegingstoestanden
		#crouching
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		head.position.y = lerp(head.position.y,1.8+crouching_depth,delta*lerp_speed)
		standing_colision_shape.disabled = true
		crouching_colision_shape.disabled = false
		#staan
	elif !ray_cast_3d.is_colliding():
		standing_colision_shape.disabled = false
		crouching_colision_shape.disabled = true
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
		#sprinten
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
		#lopen
		else:
			current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed	
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
