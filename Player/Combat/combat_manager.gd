extends Node
class_name CombatManager

@onready var body_animation_player: AnimationPlayer = $"../ModelBody/KnightBody/BodyAnimationPlayer"
@onready var player: CharacterBody3D = $".."
@onready var model_body: Node3D = $"../ModelBody"

var queue: FifoQueue = preload("res://Player/Combat/fifo_queue.gd").new()

var current_weapon: Weapon


func _ready() -> void:
	current_weapon = DoubleHSwordWeapon.new() # TODO nie wiem czy od razu bron moze dostac chlop

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack_left"):	
		add_basic_attack(current_weapon)
	if queue.is_empty():
		return
	execute_next()

func execute_next():
	var next:Attack = queue.dequeue()
	body_animation_player.play(next.animation_name)
	check_if_hitted_static(next.damage_multiplier * current_weapon.damage)
	
	#body_animation_player.play(next.animation_name)

# TODO FIXME dziala statycznie, a nie z ruchem ataku
func check_if_hitted_static(attack_damage: float):
	await get_tree().create_timer(0.7).timeout
	var space_state = player.get_world_3d().direct_space_state
	var origin = player.global_transform.origin
	var forward = -model_body.global_transform.basis.z  # Atak przed siebierm.basis.z)

	var query = PhysicsRayQueryParameters3D.create(origin, origin + forward * current_weapon.attack_range)
	query.exclude = [player]
	var result = space_state.intersect_ray(query)
	if result:
		var hit_object = result.collider
		if hit_object.has_method("_on_hit"):
			hit_object._on_hit(attack_damage)
			print("Trafiłem w:", hit_object)

func add_basic_attack(weapon: Weapon):
	queue.enqueue(weapon.basic_attacks[0]) # TODO [0] XD

# TODO do usuniecia
func add_to_queue(attack: Attack):
	queue.enqueue(attack)
	
