extends CharacterBody3D

# --- PLAYER NODES ---
@onready var head = $head
@onready var eyes = $head/eyes
@onready var standing_colision_shape = $standing_colision_shape
@onready var crouching_colision_shape = $crouching_colision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var Camera_3d = $head/eyes/Camera3D
@onready var sprint_bar := $Sprintbar

@onready var WalkAudio = $PlayerAudios/Footsteps
@onready var RunAudio = $PlayerAudios/Footsteps2

@onready var game_over_screen = $"../UI/GameOverScreen"
@onready var game_over_canvas = $"../UI/GameOverScreen/CanvasLayer" # for fade effect

# --- SPEED VARIABLES ---
var current_speed = 5.0
const crouch_speed = 3.0
const walk_speed = 5.0 
const sprint_speed = 8.0 
const jump_velocity = 4.5

# --- MOVEMENT STATES ---
var crouching = false
var walking = false
var sprinting = false

# --- HEAD BOBBING ---
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# --- INPUT VARIABLES ---
var direction = Vector3.ZERO
const mouse_sensitivty = 0.4
var crouching_depth = -0.5
var max_stamina := 400
var stamina := max_stamina
var lerp_speed = 10.0

# --- GAME OVER VARIABLES ---
var game_over_active := false
var game_over_enemy: Node3D
var rotation_duration := 0.5
var rotation_elapsed := 0.0
var start_rotation_y := 0.0
var target_rotation_y := 0.0
var fade_duration := 0.7
var fade_elapsed := 0.0
var fade_started := false

# --- READY ---
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game_over_screen.visible = false
	if game_over_canvas:
		game_over_canvas.modulate.a = 0

# --- INPUT ---
func _input(event):
	if game_over_active:
		return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivty))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivty))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# --- GAME OVER ---
func _game_over(enemy):
	if game_over_active:
		return
	print("Game Over! Collided with enemy")
	game_over_active = true
	Global.game_over_active = true 
	velocity = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	WalkAudio.stop()
	RunAudio.stop()

	# Setup smooth rotation toward enemy
	game_over_enemy = enemy
	start_rotation_y = rotation.y
	var dir = enemy.global_position - global_position
	dir.y = 0
	dir = dir.normalized()
	target_rotation_y = atan2(-dir.x, -dir.z) # fixed rotation
	rotation_elapsed = 0.0

	# Show Game Over screen (fade handled in _physics_process)
	game_over_screen.visible = true
	
	if game_over_canvas:
		game_over_canvas.modulate.a = 0

# --- PHYSICS PROCESS ---
func _physics_process(delta):
	if game_over_active:
		# Smooth rotation toward enemy
		if rotation_elapsed < rotation_duration:
			rotation_elapsed += delta
			var t = clamp(rotation_elapsed / rotation_duration, 0, 1)
			rotation.y = lerp_angle(start_rotation_y, target_rotation_y, t)
		else:
			# Start fade after rotation
			if game_over_canvas and not fade_started:
				fade_started = true
				fade_elapsed = 0.0
			if fade_started and fade_elapsed < fade_duration:
				fade_elapsed += delta
				var f = clamp(fade_elapsed / fade_duration, 0, 1)
				game_over_canvas.modulate.a = f

		# Freeze all player movement
		velocity = Vector3.ZERO
		head_bobbing_vector = Vector2.ZERO
		return

	# --- PLAYER MOVEMENT ---
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var walking_speed = walk_speed * Global.speed_walk
	var sprinting_speed = sprint_speed * Global.speed_sprint

	if Global.sprint_stamina == 1:
		Global.sprint_stamina = 0
		$Sprintbar.value = $Sprintbar.max_value

	# CROUCHING
	if Input.is_action_pressed("crouch"):
		current_speed = lerp(crouch_speed, current_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta * lerp_speed)
		standing_colision_shape.disabled = true
		crouching_colision_shape.disabled = false
		crouching = true
	elif !ray_cast_3d.is_colliding():
		standing_colision_shape.disabled = false
		crouching_colision_shape.disabled = true
		head.position.y = lerp(head.position.y, 1.8, delta * lerp_speed)
		if Input.is_action_pressed("sprint") and $Sprintbar.value > 0 and input_dir != Vector2.ZERO:
			current_speed = lerp(sprinting_speed, current_speed, delta * lerp_speed)
			sprinting = true
			walking = false
			crouching = false
			$Sprintbar.value -= 1
			sprint_bar.visible = sprinting or sprint_bar.value < max_stamina
		else:
			current_speed = lerp(walking_speed, current_speed, delta * lerp_speed)
			sprinting = false
			walking = true
			crouching = false
			if sprint_bar.value < max_stamina:
				$Sprintbar.value += 0.5
			if sprint_bar.value == max_stamina:
				sprint_bar.visible = false

	# HEAD BOBBING
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta

	if input_dir != Vector2.ZERO and is_on_floor():
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 1.25), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)

	# ENEMY COLLISION CHECK
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if global_position.distance_to(enemy.global_position) < 2.0:
			_game_over(enemy)
			break

	# GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta

	# JUMP
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# MOVE
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	# AUDIO
	if input_dir != Vector2.ZERO and is_on_floor():
		if sprinting:
			if not RunAudio.is_playing():
				RunAudio.play()
			WalkAudio.stop()
		elif walking:
			if not WalkAudio.is_playing():
				WalkAudio.play()
			RunAudio.stop()
	else:
		WalkAudio.stop()
		RunAudio.stop()


func _on_restart_button_pressed():
	# Reload the current scene
	Global.score = 0
	Global.xp = 0
	Global.enemy_speed = 1
	Global.game_over_active = false
	
	# Change to the home screen scene
	get_tree().change_scene_to_file("res://Scenes/GameScenes/HomeScreen.tscn")
