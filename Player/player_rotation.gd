extends Node3D

@onready var camera: Camera3D = %PlayerCamera
@export var rotation_speed: float = 10.0
@export var y_offset: float = 0.0

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	# Create a horizontal plane at the node's height + y_offset
	var plane = Plane(Vector3.UP, global_position.y + y_offset)
	
	# Find where the ray intersects the horizontal plane
	var target_pos = plane.intersects_ray(from, to)
	
	if target_pos:
		# Look at the target position, but only rotate around Y axis
		var look_target = Vector3(target_pos.x, global_position.y, target_pos.z)
		
		# Smoothly rotate towards the target
		var current_transform = global_transform
		var target_transform = current_transform.looking_at(look_target, Vector3.UP)
		
		# Interpolate rotation for smooth movement
		global_transform = current_transform.interpolate_with(target_transform, rotation_speed * delta)
