extends Node3D

class_name LifeComponent

signal died
signal took_damage(amount: int, life_after_damage: int, life_before_damage: int)
signal current_life_changed(value: int)

@export var max_life: int = 100

@export var current_life: int: 
	set(value):
		current_life = clamp(value, 0, max_life)
		current_life_changed.emit(current_life)

func _ready() -> void:
	current_life = max_life

func take_damage(amount: int) -> void:
	var life_before_damge = current_life
	current_life -= amount
	took_damage.emit(amount, current_life, life_before_damge)

	if current_life <= 0:
		died.emit()

func heal(amount: int) -> void:
	current_life += amount

func is_dead() -> bool:
	return current_life <= 0
