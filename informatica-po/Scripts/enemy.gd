extends CharacterBody3D

const  speed_base := 1.0

@onready var nav_agent = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $"ModelPivot/Zombie Walk"/AnimationPlayer
@onready var skeleton: Skeleton3D = $"ModelPivot/Zombie Walk"/Skeleton3D

const HIPS_BONE_NAME := "mixamorig_Hips"

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
	
	var speed =speed_base*Global.enemy_speed
	
	nav_agent.target_position = player.global_position + offset
	var next_point = nav_agent.get_next_path_position()
	var desired_velocity = (next_point - global_position).normalized() * speed

	nav_agent.velocity = desired_velocity
	velocity = nav_agent.get_velocity()

	move_and_slide()

	#Rotates to face the player
	if velocity.length() > 0.1:
		var direction = velocity.normalized()
		var target_yaw = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 6.0 * delta)

# Get the Animation resource
	if velocity.length() > 0.1:
		if anim_player.current_animation != "mixamo_com":
			anim_player.play("mixamo_com")

	var hips_index = skeleton.find_bone(HIPS_BONE_NAME)  # returns int
	if hips_index != -1:
		var pose = skeleton.get_bone_global_pose(hips_index)
		pose.origin.z = 0
		skeleton.set_bone_global_pose_override(hips_index, pose, 1.0, true)
		
func die():
	Global.score += 100
	Global.xp +=10
	queue_free()
