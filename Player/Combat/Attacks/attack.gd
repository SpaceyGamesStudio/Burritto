extends Node 
class_name Attack

@export var damage_multiplier: float = 1
var animation_name: StringName
var animation_duration: float
#var min_animation_duration: float # TODO To bedzie zastapione raczej klasa NextMeleeAttack czy cos

# TODO jakie parametry i typ zwracany?
func execute_attack():
	push_error("UNIMPLEMENTED ABSTRACT METHOD Attack.execute_attack()")















## TODO wygenerowane z chata gpt
#@export var attack_name: String = "default_attack"
#@export var animation_name: String = "attack_1"
#@export var duration: float = 0.5
#
## TODO
#var damage = 10
#var attack_duration = 0.3
#var cooldown = 0.1
#var possible_next_attacks
#var knockback_force
#var	status_effect
#var status_effect_duration = 2.0
#
#@export var attack_list: Array[Attack] # Lista dostępnych ataków
##@onready var animation_tree = $AnimationTree
##@onready var animation_state = animation_tree.get("parameters/playback")
#
#var attack_queue: Array[Attack] = []
#var is_attacking = false
#
#func _unhandled_input(event):
	#if event.is_action_pressed("attack"):
		#queue_attack(attack_list[0]) # Dodaj pierwszy atak z listy
	#elif event.is_action_pressed("special_attack"):
		#queue_attack(attack_list[1]) # Dodaj drugi atak z listy
#
#func queue_attack(attack: Attack):
	#if is_attacking:
		#attack_queue.append(attack) # Jeśli trwa atak, dodaj do kolejki
	#else:
		#execute_attack(attack) # Jeśli nie, wykonaj od razu
#
#func execute_attack(attack: Attack):
	#is_attacking = true
	##animation_state.travel(attack.animation_name) # Odtwórz animację
	#await get_tree().create_timer(attack.duration).timeout
	#is_attacking = false
	#
	#if attack_queue.size() > 0:
		#var next_attack = attack_queue.pop_front() # Pobierz następny atak z kolejki
		#execute_attack(next_attack)
