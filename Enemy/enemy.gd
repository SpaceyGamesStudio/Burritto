extends CharacterBody3D

@export var WONDERING_SPEED: float = 1.0
@export var WONDERING_POSITION_DEADZONE: float = 0.5
@export var WONDERING_ZONE_RADIUS: float = 3.0

@export var AGGRO_SPEED: float = 2.0

@export var MAX_DISTANCE: float = 10.0

@onready var hitbox: Area3D = %Hitbox
@onready var life_component: LifeComponent = %LifeComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var aggro_range: Area3D = %AggroRange
@onready var move_animation_tree: AnimationTree = %AnimationTree
@onready var weapon: WeaponComponent = %Weapon

var wondering_target_position: Vector3 = Vector3.ZERO
var current_speed: float = WONDERING_SPEED
var is_attacking: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.area_entered.connect(on_hit)
	life_component.died.connect(on_died)
	weapon.player_entered_hit_range.connect(on_enter_hit_range)
	weapon.player_exited_hit_range.connect(on_exit_hit_range)
	weapon.player_hit.connect(on_player_hit)
	move_animation_tree.active = true
	navigate_to_random_position()
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if(life_component.is_dead()):
		return

	var destination: Vector3 = navigation_agent.get_next_path_position()
	var local_direction: Vector3 = destination - global_position

	if aggro_range.get_overlapping_areas().size() > 0:
		aggro_movement(local_direction, destination)
		return

	wondering_movement(local_direction, destination)

func get_random_vector3() -> Vector3:
	var random_x: float = randf_range(-WONDERING_ZONE_RADIUS, WONDERING_ZONE_RADIUS)
	var random_z: float = randf_range(-WONDERING_ZONE_RADIUS, WONDERING_ZONE_RADIUS)
	return Vector3(random_x, 0, random_z)

func navigate_to_random_position() -> void:
	navigation_agent.set_target_position(get_random_vector3())

func on_hit(area: Area3D) -> void:
	life_component.take_damage(10)

func on_died() -> void:
	move_animation_tree.active = false
	animation_player.play("Death_A")
	await animation_player.animation_finished
	queue_free()

func wondering_movement(local_direction: Vector3, destination) -> void:
	var distance: float = local_direction.length()
	var direction: Vector3 = local_direction.normalized()

	if distance < WONDERING_POSITION_DEADZONE:
		navigate_to_random_position()
	
	velocity = direction * WONDERING_SPEED
	move_animation_tree['parameters/conditions/is_walking'] = true
	move_animation_tree['parameters/conditions/is_running'] = false
	move_animation_tree['parameters/conditions/is_idle'] = false
	move_animation_tree['parameters/FromWalkToRun/blend_position'] = 0.0
	
	look_at_from_position(global_position, destination)
	move_and_slide()

func aggro_movement(local_direction: Vector3, destination: Vector3) -> void:
	look_at_from_position(global_position, destination)
	aggro_range.look_at(aggro_range.get_overlapping_areas()[0].global_position)

	if(is_attacking):
		move_animation_tree.active = false
		animation_player.play("Unarmed_Melee_Attack_Punch_A")
		await animation_player.animation_finished
		move_animation_tree.active = true
		velocity = Vector3.ZERO
		return

	navigation_agent.set_target_position(aggro_range.get_overlapping_areas()[0].global_position)
	var direction: Vector3 = local_direction.normalized()
	velocity = direction * AGGRO_SPEED
	move_animation_tree['parameters/conditions/is_walking'] = false
	move_animation_tree['parameters/conditions/is_running'] = true
	move_animation_tree['parameters/conditions/is_idle'] = false
	move_animation_tree['parameters/FromWalkToRun/blend_position'] = 1.0

	move_and_slide()

func on_enter_hit_range():
	is_attacking = true


func on_exit_hit_range():
	await animation_player.animation_finished
	is_attacking = false

func on_player_hit():
	print("player hitted")