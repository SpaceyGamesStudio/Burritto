extends CharacterBody3D

class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var life_component: LifeComponent = %LifeComponent

func _ready() -> void:
	PlayerGlobal.take_damage.connect(on_damage_take)
	life_component.died.connect(on_death)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	movement()
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if event.is_action_pressed("attack"):
		attack()

func movement() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func attack() -> void:
	animation_player.play("2H_Melee_Attack_Slice")

func on_damage_take(damage: float) -> void:
	life_component.take_damage(damage)

func on_death() -> void:
	get_tree().reload_current_scene()
