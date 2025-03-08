extends Camera3D

@onready var camera_node: Node3D = $".."
@onready var player_camera: Camera3D = %PlayerCamera

@export var basic_camera_rotation_x: float = -45
@export var zoom_speed: float = 0.4
@export var rotation_speed: float = 0.0075
@export var min_zoom: float = 6
@export var max_zoom: float = 24.0
const basic_camera_y: float = 12.5
const basic_camera_rotation_x_step = 8.5

func _ready() -> void:
	basic_camera_rotation_x -= basic_camera_rotation_x_step
	camera_position_y()
	camera_rotation_x()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			size = clamp(size - zoom_speed, min_zoom, max_zoom)
			camera_position_y()
			camera_rotation_x()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			size = clamp(size + zoom_speed, min_zoom, max_zoom)
			camera_position_y()
			camera_rotation_x()
			
func _input(event: InputEvent):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if event is InputEventMouseMotion:
			var x = event.relative.x #if is_mouse_below_half_screen() else -event.relative.x
			var y = event.relative.y if is_mouse_on_left_half_screen() else -event.relative.y
			camera_node.rotation.y -= (x - y) * rotation_speed # * (size / max_zoom)
			
		elif event is InputEventMouseButton and event.is_double_click():
			size = min_zoom if abs(size - min_zoom) > abs(size - max_zoom) else max_zoom		
			camera_position_y()
			camera_rotation_x()

func is_mouse_below_half_screen() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_height = get_viewport().get_visible_rect().size.y
	return mouse_pos.y > screen_height / 2			
	
func is_mouse_on_left_half_screen() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_width = get_viewport().get_visible_rect().size.x
	return mouse_pos.x > screen_width / 2		
			
func camera_position_y() -> void:
	position.y = basic_camera_y - (1.5 * (max_zoom / size))
	
func camera_rotation_x() -> void:
	player_camera.rotation.x = deg_to_rad(basic_camera_rotation_x + (max_zoom / size * basic_camera_rotation_x_step))


# TODO skrypt jaki byl pod cameranode 
#extends Camera3D
#
#@onready var camera_node: Node3D = $".."
#@onready var player_camera: Camera3D = %PlayerCamera
#
#@export var basic_camera_rotation_x: float = -45
#@export var zoom_speed: float = 0.4
#@export var rotation_speed: float = 0.0075
#@export var min_zoom: float = 6
#@export var max_zoom: float = 24.0
#const basic_camera_y: float = 12.5
#const basic_camera_rotation_x_step = 8.5
#
#func _ready() -> void:
	#basic_camera_rotation_x -= basic_camera_rotation_x_step
	#camera_position_y()
	#camera_rotation_x()
#
#func _unhandled_input(event: InputEvent):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#size = clamp(size - zoom_speed, min_zoom, max_zoom)
			#camera_position_y()
			#camera_rotation_x()
		#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#size = clamp(size + zoom_speed, min_zoom, max_zoom)
			#camera_position_y()
			#camera_rotation_x()
			#
#func _input(event: InputEvent):
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		#if event is InputEventMouseMotion:
			#var x = event.relative.x #if is_mouse_below_half_screen() else -event.relative.x
			#var y = event.relative.y if is_mouse_on_left_half_screen() else -event.relative.y
			#camera_node.rotation.y -= (x - y) * rotation_speed # * (size / max_zoom)
			#
		#elif event is InputEventMouseButton and event.is_double_click():
			#size = min_zoom if abs(size - min_zoom) > abs(size - max_zoom) else max_zoom		
			#camera_position_y()
			#camera_rotation_x()
#
#func is_mouse_below_half_screen() -> bool:
	#var mouse_pos = get_viewport().get_mouse_position()
	#var screen_height = get_viewport().get_visible_rect().size.y
	#return mouse_pos.y > screen_height / 2			
	#
#func is_mouse_on_left_half_screen() -> bool:
	#var mouse_pos = get_viewport().get_mouse_position()
	#var screen_width = get_viewport().get_visible_rect().size.x
	#return mouse_pos.x > screen_width / 2		
			#
#func camera_position_y() -> void:
	#position.y = basic_camera_y - (1.5 * (max_zoom / size))
	#
#func camera_rotation_x() -> void:
	#player_camera.rotation.x = deg_to_rad(basic_camera_rotation_x + (max_zoom / size * basic_camera_rotation_x_step))
