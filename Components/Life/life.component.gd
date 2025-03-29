extends Node3D

class_name LifeComponent

signal died
signal took_damage(amount: float, life_after_damage: int, life_before_damage: int)
signal current_life_changed(value: int)

@export var max_life: float = 100.0

@export var current_life: float: 
	set(value):
		current_life = clamp(value, 0, max_life)
		current_life_changed.emit(current_life)

func _ready() -> void:
	current_life = max_life

func take_damage(amount: float) -> float:
	var life_before_damge = current_life
	current_life -= amount
	took_damage.emit(amount, current_life, life_before_damge)

	if current_life <= 0:
		died.emit()

	return current_life

func heal(amount: int) -> void:
	current_life += amount

func is_dead() -> bool:
	return current_life <= 0
