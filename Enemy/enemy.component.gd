extends Node3D

class_name EnemyComponent

@onready var area: Area3D = %Area3D

@onready var life_component: LifeComponent = %LifeComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.area_entered.connect(on_area_entered)
	life_component.died.connect(on_died)
	pass # Replace with function body.


func on_area_entered(area: Area3D) -> void:
	life_component.take_damage(10)
	print(life_component.current_life)

func on_died() -> void:
	animation_player.play("Death_A")
	await animation_player.animation_finished
	queue_free()
