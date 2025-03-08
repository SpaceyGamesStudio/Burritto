extends Weapon
class_name DoubleHSwordWeapon

@export var hitbox: Area2D
@export var hitbox_shape: CollisionShape2D


func _init() -> void:
	#get_parent().
	attack_range = 2.2
	damage = 200.0
	
	var attack1 = MeleeAttack.new()
	attack1.animation_name = "2H_Melee_Attack_Chop"
	attack1.animation_duration = 1.6
	attack1.damage_multiplier = 1.0 # todo default to jest
	basic_attacks.append(attack1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
