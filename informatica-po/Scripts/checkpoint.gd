extends Node3D



var colision = 0


func _on_myarea_body_entered(body):
	if body.name == "player" and colision == 0:
		colision = 1
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
