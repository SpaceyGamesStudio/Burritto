extends CharacterBody3D
@onready var camera: Camera3D = %PlayerCamera
@onready var camera_node: Node3D = $CameraNode
@onready var model_body: Node3D = $ModelBody
@onready var model_legs: Node3D = $ModelLegs
@onready var legs_animation_player: AnimationPlayer = $ModelLegs/KnightLegs/LegsAnimationPlayer
#@onready var body_animation_player: AnimationPlayer = $ModelBody/KnightBody/BodyAnimationPlayer

@export var body_rotation_speed: float = 7.5
@export var SPEED: float = 666
@export var is_attacking: bool = false
@export var is_moving: bool = false
@export var slide_delta: float = 100 # Mozna zmniejszyc jesli bohater znajduje sie na lodzie np

const ANGLE_90 = deg_to_rad(90)
const ANGLE_45 = deg_to_rad(45)
const ANGLE_135 = deg_to_rad(135) 
const ANGLE_270 = deg_to_rad(270) 

const MOVING_SIDEWAY_FRONT_SPEED_MULTIPLER = 0.9;
const MOVING_SIDEWAY_BACK_SPEED_MULTIPLER = 0.7;
const MOVING_BACKWARD_SPEED_MULTIPLER = 0.5;

var rotation_state = 0; # 0 <45d; 1 <90d; 2 <135d; 3 >135d 
var last_movement_direction: Vector3 = Vector3(0.0, 0.0, 0.0)


#func _process(delta):
	##TODO RESET NA SRODEK MAPY
	#if Input.is_action_just_pressed("jump"):
		#position = Vector3(0,0,0)

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")			
	#var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, spring_arm_3d.rotation.y)
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_node.rotation.y)
	attack(direction)
	if input_dir:
		last_movement_direction = direction
		movement(delta, direction)
	if !input_dir || is_attacking:
		sliding_stop_moving(delta)
	move_and_slide()
	if !is_attacking:
		rotate_towards_target(delta, direction)
	
	
#await body_animation_player.animation_finished # TODO
#if animationPlayer.is_playing(): return  # TODO
# TODO trzeba zgrac z movementem, ze podczas ruchu nogi s
func attack(movement_direction: Vector3):
	pass # TODO XD
	#is_attacking = true; # TODO is_attacking trzeba jakos z managerem ubrac
	
	#var one = "2H_Melee_Attack_Slice"
	#var two = "2H_Melee_Attack_Stab"
	#var thr = "2H_Melee_Attack_Chop"
	#var fou = "2H_Melee_Attack_Spin"
	#stop_animations()
	##q_animations(one)
	##q_animations(thr)
	##q_animations(fou)
	##q_animations(thr)
	#play_animations(one)
	#await body_animation_player.animation_finished
	#play_animations(thr)
	#body_animation_player.animation_set_next(thr, two) # odtworzy sie dwa razy po calej kolejce XD
	#print(body_animation_player.get_queue())
	#play_animations("Dualwield_Melee_Attack_Chop")
	#await get_tree().create_timer(1.2).timeout
	#play_animations("2H_Melee_Attack_Stab")
	#await get_tree().create_timer(1.5).timeout
	#play_animations("2H_Melee_Attack_Spin")
	#await get_tree().create_timer(2.2).timeout
	#is_attacking = false;
	
func movement(delta: float, direction: Vector3) -> void:
	if !is_attacking:
		var movement_speed = calculate_movement_speed(delta)
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
		is_moving = true # TODO ? XD caly is_moving wtf
	else:
		is_moving = false
		#play_animations("Walking_B")

func sliding_stop_moving(delta: float) -> void:
	if !is_attacking: 
		play_animations("Idle") # TODO czy to powinno tu byc
	var slide_delta_delta = slide_delta * delta
	velocity.x = move_toward(velocity.x, 0, slide_delta_delta)
	velocity.z = move_toward(velocity.z, 0, slide_delta_delta)
	is_moving = false

func rotate_towards_target(delta, direction: Vector3):
	if !is_attacking:
		var mouse_position = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_position)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 1000

		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_end))

		if result:
			var look_target = result.position
			var target_direction = (look_target - global_position).normalized()
			var target_rotation_y = atan2(target_direction.x, target_direction.z) + PI
			var new_rotation_y = lerp_angle(model_body.rotation.y, target_rotation_y, delta * body_rotation_speed)
			# TODO zakomentowane /- ograniczenie rotacji
				#var min_rotation = model_legs.rotation.y - ANGLE_45
				#var max_rotation = model_legs.rotation.y + ANGLE_45
				#new_rotation_y = clamp(new_rotation_y, min_rotation, max_rotation)	
			model_body.rotation.y = new_rotation_y
			if direction.x:
				last_movement_direction.x = -last_movement_direction.x
			var angle_last_movement_direction = Vector2(last_movement_direction.x, last_movement_direction.z).angle()
			var angle_diff = get_angle_difference(angle_last_movement_direction + ANGLE_90, new_rotation_y)
			if angle_diff < ANGLE_45:
				rotation_state = 0
			elif angle_diff < ANGLE_90:
				rotation_state = 1
			elif angle_diff < ANGLE_135:
				rotation_state = 2
			else:
				rotation_state = 3
			if direction:
				if rotation_state < 2:
					model_legs.rotation.y = atan2(-direction.x, -direction.z)
				else:
					model_legs.rotation.y = atan2(direction.x, direction.z)
			else:
				model_legs.rotation.y = new_rotation_y
		
func calculate_movement_speed(delta) -> float:
	var delta_speed = delta * SPEED
	if rotation_state == 0:
		play_animations("Running_A")
		return delta_speed
	elif rotation_state == 1:
		play_animations("Running_B")
		return delta_speed * MOVING_SIDEWAY_FRONT_SPEED_MULTIPLER
	elif rotation_state == 2:
		play_animations_backwards("Walking_A", 2.0)
		return delta_speed * MOVING_SIDEWAY_BACK_SPEED_MULTIPLER
	else:
		play_animations("Walking_Backwards", 1.6)
		return delta_speed * MOVING_BACKWARD_SPEED_MULTIPLER
	
func get_angle_difference(angle1: float, angle2: float) -> float:
	var diff = fposmod(angle2 - angle1 + PI, TAU) - PI
	return abs(diff)  # Absolutna wartość różnicy kątowej
	
func play_animations(animation: StringName, custom_speed: float = 1.0) -> void:
	pass # TODO
	#body_animation_player.play(animation, -1, custom_speed)
	#legs_animation_player.play(animation, -1, custom_speed)	
	
func play_animations_backwards(animation: StringName, custom_speed: float = 1.0) -> void:
	pass # TODO "play_animations w player tymczasowo OFF"
	#body_animation_player.play(animation, -1, -custom_speed, true)
	#legs_animation_player.play(animation, -1, -custom_speed, true)	

# TODO byc moze do wywalenia
func pause_animations() -> void:
	#body_animation_player.pause() # TODO
	legs_animation_player.pause()
	
func stop_animations() -> void:
	#body_animation_player.stop()
	legs_animation_player.stop()
	
func q_animations(animation: StringName) -> void:
	#body_animation_player.queue(animation)
	legs_animation_player.queue(animation)
