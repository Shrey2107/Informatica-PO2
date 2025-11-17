extends Node3D

#flashlight aan en uit zetten
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("Toggle flashlight") and $Battery.value >0 :
		$SpotLight3D.light_energy = 12.0
	else:
		$SpotLight3D.light_energy = 0.0
	

func _physics_process(delta: float) -> void:
	if $SpotLight3D.light_energy == 12.0:
		$Battery.value -= 1
