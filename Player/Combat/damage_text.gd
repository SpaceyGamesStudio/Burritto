extends Control

@export var float_speed: float = 50.0 

const lifetime: float = 0.4
const half_lifetime: float = lifetime / 2;
var random_bool := bool(randi_range(0, 1))

func _ready():
	$AnimationPlayer.play("pop_up")
	$Timer.start(lifetime) # TODO zamiast tego przydałoby się reużywać xD

func _process(delta):
	var time_left = $Timer.time_left
	
	if time_left > 0.34:
		position.y -= 21 * float_speed * delta
	elif time_left < 0.23:
		position.y -= 7 * float_speed * delta
		if random_bool:
			position.x += 21.0 * float_speed * delta
		else:
			position.x -= 21.0 * float_speed * delta


func set_damage(value: int, position_3d: Vector3):
	$Label.text = str(value)
	position_3d.y += 1.0

	# Przekształcenie pozycji 3D na 2D
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	if camera:
		position = camera.unproject_position(position_3d)

func _on_Timer_timeout():
	queue_free()  # TODO ! Usunięcie liczby po czasie ! over fire !
