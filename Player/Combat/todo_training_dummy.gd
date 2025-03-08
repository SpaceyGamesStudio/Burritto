extends StaticBody3D

# TODO
func _ready():
	print("Training Dummy Ready on x = %s, z = %s" % [global_position.x, global_position.z])

func _on_hit(damage):
	print("Hit detected! Damage:", damage)
	var damage_text = preload("res://Player/Combat/damage_text.tscn").instantiate()
	get_tree().current_scene.add_child(damage_text)  # Dodanie do sceny
	damage_text.set_damage(damage, global_position)
