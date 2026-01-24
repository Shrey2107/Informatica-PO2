extends Node3D

@onready var light:= $SpotLight3D


func _physics_process(delta):
	Global.battery = $Battery.value
	
	
	if $SpotLight3D.light_energy == 12.0:
		$Battery.value -= 1
		kill_enemies_in_light()

	
	if Global.refills == 1:
		Global.refills = 0;
		$Battery.value = $Battery.max_value
	


#flashlight aan en uit zetten
func _input(event):
	if Input.is_action_pressed("Toggle flashlight") and Global.battery >0 :
		$SpotLight3D.light_energy = 12.0
	else:
		$SpotLight3D.light_energy = 0.0
	
	
func kill_enemies_in_light():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_enemy_in_light(enemy):
			enemy.die()
			

func is_enemy_in_light(enemy: Node3D) -> bool:
	var mesh_node := enemy.get_node_or_null("MeshInstance3D")
	if mesh_node == null:
		return false

	var aabb: AABB = mesh_node.get_aabb()

	var min := aabb.position
	var max := aabb.position + aabb.size
	var center := aabb.get_center()

	# LOCAL-space sample points
	var local_points := [
		# corners
		Vector3(min.x, min.y, min.z),
		Vector3(max.x, min.y, min.z),
		Vector3(min.x, max.y, min.z),
		Vector3(min.x, min.y, max.z),
		Vector3(max.x, max.y, min.z),
		Vector3(max.x, min.y, max.z),
		Vector3(min.x, max.y, max.z),
		Vector3(max.x, max.y, max.z),

		# face centers
		Vector3(center.x, min.y, center.z),
		Vector3(center.x, max.y, center.z),
		Vector3(min.x, center.y, center.z),
		Vector3(max.x, center.y, center.z),
		Vector3(center.x, center.y, min.z),
		Vector3(center.x, center.y, max.z),

		# center
		center
	]

	for p_local in local_points:
		var p_global: Vector3 = mesh_node.global_transform * p_local
		if point_in_spotlight(p_global):
			return true


	return false


func point_in_spotlight(point: Vector3) -> bool:
	var dir = point - light.global_position
	var distance = dir.length()

	if distance > light.spot_range:
		return false

	dir = dir.normalized()
	var forward = -light.global_transform.basis.z
	var dot = forward.dot(dir)

	var angle_limit = cos(deg_to_rad(light.spot_angle * 0.5))
	return dot >= angle_limit
