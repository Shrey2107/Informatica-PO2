extends Label

func _physics_process(delta: float) -> void:
	text = "Score: %s" % Global.score
