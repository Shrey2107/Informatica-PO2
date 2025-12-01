extends Node3D

func _physics_process(delta):
	Global.battery = $Battery.value
	
	
	if $SpotLight3D.light_energy == 12.0:
		$Battery.value -= 1
	
	if Global.refills == 1:
		Global.refills = 0;
		$Battery.value = $Battery.max_value
	


#flashlight aan en uit zetten
func _input(event):
	if Input.is_action_pressed("Toggle flashlight") and Global.battery >0 :
		$SpotLight3D.light_energy = 12.0
	else:
		$SpotLight3D.light_energy = 0.0
	
