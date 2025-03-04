extends CharacterBody3D

@onready var model: Node3D = $Model
@export var SPEED: float = 100.0

func _physics_process(delta: float) -> void:
	movement(delta)
	move_and_slide()

func movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_direction := Vector3.ZERO
	var y_2d := -model.global_transform.basis.z
	var x_2d := model.global_transform.basis.x
	
	move_direction -= input_dir.y * y_2d
	move_direction += input_dir.x * x_2d

	move_direction = move_direction.normalized()
	velocity = move_direction * SPEED * delta
	move_and_slide()
