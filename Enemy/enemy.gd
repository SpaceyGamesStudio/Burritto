extends CharacterBody3D

@export var SPEED: float = 1.0
@export var WONDERING_POSITION_DEADZONE: float = 0.5
@export var WONDERING_ZONE_RADIUS: float = 3.0

@export var MAX_DISTANCE: float = 10.0

@onready var area: Area3D = %Area3D

@onready var life_component: LifeComponent = %LifeComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D

var wondering_target_position: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.area_entered.connect(on_area_entered)
	life_component.died.connect(on_died)
	navigate_to_random_position()
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var destination: Vector3 = navigation_agent.get_next_path_position()
	var local_direction: Vector3 = destination - global_position
	var distance: float = local_direction.length()
	
	if distance < WONDERING_POSITION_DEADZONE:
		navigate_to_random_position()
	
	var direction: Vector3 = local_direction.normalized()
	velocity = direction * SPEED
	look_at_from_position(global_position, destination)
	move_and_slide()

func get_random_vector3() -> Vector3:
	var random_x: float = randf_range(-WONDERING_ZONE_RADIUS, WONDERING_ZONE_RADIUS)
	var random_z: float = randf_range(-WONDERING_ZONE_RADIUS, WONDERING_ZONE_RADIUS)
	return Vector3(random_x, 0, random_z)

func navigate_to_random_position() -> void:
	navigation_agent.set_target_position(get_random_vector3())

func on_area_entered(area: Area3D) -> void:
	life_component.take_damage(10)

func on_died() -> void:
	animation_player.play("Death_A")
	await animation_player.animation_finished
	queue_free()
