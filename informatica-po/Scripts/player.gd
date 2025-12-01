extends CharacterBody3D

#speler nodes
@onready var head = $head
@onready var eyes = $head/eyes
@onready var standing_colision_shape = $standing_colision_shape
@onready var crouching_colision_shape = $crouching_colision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var Camera_3d = $head/eyes/Camera3D

#snelheden variables
var current_speed = 5.0
const crouch_speed = 3.0
const walking_speed = 5.0 
const sprinting_speed = 8.0 
const  jump_velocity = 4.5

#looptoestanden
var crouching = false
var walking = false
var sprinting = false

#hoofd beweegingen tijdens het lopen variablen
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.00

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


func _physics_process(delta):
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	#bewegingstoestanden
		#crouching
	if Input.is_action_pressed("crouch"):
		current_speed = lerp(crouch_speed,current_speed,delta*lerp_speed)
		head.position.y = lerp(head.position.y,1.8+crouching_depth,delta*lerp_speed)
		standing_colision_shape.disabled = true
		crouching_colision_shape.disabled = false
		crouching = true
		walking = false
		sprinting = false
		#staan
	elif !ray_cast_3d.is_colliding():
		standing_colision_shape.disabled = false
		crouching_colision_shape.disabled = true
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
		#sprinten
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(sprinting_speed,current_speed,delta*lerp_speed)
			sprinting = true
			walking = false
			crouching = false
		#lopen
		else:
			current_speed = lerp(walking_speed,current_speed,delta*lerp_speed)
			sprinting = false
			walking = true
			crouching = false
			
	#hoofd beweegingen tijdens het lopen
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif walking: 
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed*delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
	
	if input_dir != Vector2.ZERO && is_on_floor():
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/1.25),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y,0.0,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x,0.0	,delta*lerp_speed)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		
		
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed	
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
