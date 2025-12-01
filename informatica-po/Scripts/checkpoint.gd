extends Node3D

var colision = 0

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if body.name == "player" and colision == 0:
		colision = 1
		Global.refills = 1
		Global.sprint_stamina = 1




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
