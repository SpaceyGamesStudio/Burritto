extends Sprite3D

@export var life_component: LifeComponent

@onready var life_bar: ProgressBar = %Status

var life_bar_next_value: int 

func _ready() -> void:
	life_component.died.connect(on_died)
	life_component.current_life_changed.connect(on_current_life_change)

	life_bar.max_value = life_component.max_life
	life_bar_next_value =life_component.current_life
	life_bar.value = life_component.current_life

func on_died() -> void:
	queue_free()

func _process(delta: float) -> void:
	life_bar.value = lerp(float(life_bar.value), float(life_bar_next_value), delta * 20)

func on_current_life_change(value: int) -> void:
	life_bar_next_value = value
	print('lifebar', life_bar.value)
