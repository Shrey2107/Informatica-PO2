extends Node3D

var colision: int = 1 # 1 = on cooldown, 0 = ready

func _ready():
	visible = false # Start hidden
	
	

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if colision == 0 and body.is_in_group("Player"):
		colision = 1
		var time = 60 * Global.batt_spawn_mult
		time = clamp(time, 5, 60)
		$Timer1.wait_time = time
		$Timer1.start()
		Global.refills = 1
		Global.sprint_stamina = 1
		visible = false # hide when picked up


func _on_timer_timeout() -> void:
	colision = 0
	visible = true # show when ready again
