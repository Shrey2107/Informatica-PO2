extends Node3D

var colision = 0

var float_speed = 2.0
var float_height = 0.1
var rotate_speed = 1.5

var start_y


func _ready():
	start_y = position.y


func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if body.name == "player" and colision == 0:
		colision = 1
		Global.refills = 1
		Global.sprint_stamina = 1
		queue_free()  # deletes this node


# Called every frame
func _process(delta: float) -> void:

	# rotate battery
	rotate_y(rotate_speed * delta)

	# floating animation
	position.y = start_y + sin(Time.get_ticks_msec() * 0.002 * float_speed) * float_height
