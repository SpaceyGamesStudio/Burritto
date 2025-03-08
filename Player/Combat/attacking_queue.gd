class_name AttackQueueManager extends Node


# Sygnały
signal attack_started(attack_name: String)
signal attack_ended(attack_name: String)
signal queue_cleared()

# Referencja do postaci
@export var character: CharacterBody2D

# Referencja do AnimationPlayer
@export var animation_player: AnimationPlayer

# Słownik załadowanych ataków
var attacks = {}

# Kolejka ataków
var attack_queue = []

# Aktualnie wykonywany atak
var current_attack = null
var is_attacking = false
var attack_cooldown_timer = 0.0

# Mapowanie przycisków do ataków
@export var light_attack_button = "attack_light"
@export var heavy_attack_button = "attack_heavy"
@export var special_attack_button = "attack_special"

# Lista podstawowych ataków dostępnych bez łączenia
@export var base_attacks = {
	"light": "light_attack",
	"heavy": "heavy_attack",
	"special": "special_attack"
}


# TODO kod jest z chatgpt, odpiety od node'a
func _ready():
	print("Hierarchie atakow mozna podzielic na: atak -> melee i range; melee -> jednoreczna, dwureczna; ranged -> strzelany (w tym magiczny raczej), rzucany\nAle poki co to niech zostanie jak jest :3")
	print("Trzeba tez zrobic skrypty dla bronii i musza zawierac m.in. hitboxy swoje")
	
	# Załaduj wszystkie ataki
	#load_attacks()

# TODO Chatted GPT xD
#func load_attacks():
	## W prawdziwej implementacji można załadować ataki z plików zasobów
	## Tutaj dla przykładu tworzymy je ręcznie
	#
	## Atak lekki
	#var light_attack = Attack.new()
	#light_attack.attack_name = "light_attack"
	#light_attack.animation_name = "attack_light"
	#light_attack.damage = 10
	#light_attack.attack_duration = 0.3
	#light_attack.cooldown = 0.1
	#light_attack.possible_next_attacks = ["light_attack_combo", "heavy_attack"]
	#
	## Combo po lekkim ataku
	#var light_combo = Attack.new()
	#light_combo.attack_name = "light_attack_combo"
	#light_combo.animation_name = "attack_light_combo"
	#light_combo.damage = 15
	#light_combo.attack_duration = 0.4
	#light_combo.cooldown = 0.2
	#light_combo.possible_next_attacks = ["heavy_attack", "special_attack"]
	#
	## Ciężki atak
	#var heavy_attack = Attack.new()
	#heavy_attack.attack_name = "heavy_attack"
	#heavy_attack.animation_name = "attack_heavy"
	#heavy_attack.damage = 25
	#heavy_attack.attack_duration = 0.7
	#heavy_attack.cooldown = 0.3
	#heavy_attack.possible_next_attacks = ["special_attack"]
	#heavy_attack.knockback_force = 10.0
	#
	## Specjalny atak
	#var special_attack = Attack.new()
	#special_attack.attack_name = "special_attack"
	#special_attack.animation_name = "attack_special"
	#special_attack.damage = 40
	#special_attack.attack_duration = 1.0
	#special_attack.cooldown = 0.5
	#special_attack.status_effect = "stun"
	#special_attack.status_effect_duration = 2.0
	#
	## Dodaj ataki do słownika
	#attacks["light_attack"] = light_attack
	#attacks["light_attack_combo"] = light_combo
	#attacks["heavy_attack"] = heavy_attack
	#attacks["special_attack"] = special_attack
#
#func _process(delta):
	## Obsługa timera cooldown
	#if attack_cooldown_timer > 0:
		#attack_cooldown_timer -= delta
	#
	## Jeśli nie atakujemy i mamy coś w kolejce, wykonaj następny atak
	#if !is_attacking and attack_queue.size() > 0 and attack_cooldown_timer <= 0:
		#execute_next_attack()
#
##TODO
##func _input(event):
	## Jeśli gracz naciska przycisk, dodaj odpowiedni atak do kolejki
	##if event.is_action_pressed(light_attack_button):
		##queue_attack("light")
	##elif event.is_action_pressed(heavy_attack_button):
		##queue_attack("heavy")
	##elif event.is_action_pressed(special_attack_button):
		##queue_attack("special")
#
## Dodaje atak do kolejki na podstawie typu
#func queue_attack(attack_type: String):
	#var attack_name = base_attacks[attack_type]
	#
	## Jeśli wykonujemy atak, sprawdź czy można połączyć go z następnym
	#if current_attack != null:
		## Sprawdź czy aktualny atak może być połączony z nowym
		#if !current_attack.can_chain_to(attack_name):
			## Jeśli nie można połączyć, użyj podstawowego ataku tego typu
			#attack_name = base_attacks[attack_type]
		## W przeciwnym razie atak zostanie dodany do kolejki
	#
	## Dodaj atak do kolejki
	#if attacks.has(attack_name):
		#attack_queue.append(attack_name)
	#else:
		#print("Nieznany atak: ", attack_name)
#
## Wykonuje następny atak z kolejki
#func execute_next_attack():
	#if attack_queue.size() > 0:
		#var next_attack_name = attack_queue.pop_front()
		#current_attack = attacks[next_attack_name]
		#
		## Rozpocznij atak
		#is_attacking = true
		#
		## Odtwórz animację
		#if animation_player and animation_player.has_animation(current_attack.animation_name):
			#animation_player.play(current_attack.animation_name)
			#
			## Podłącz sygnał zakończenia animacji
			#if !animation_player.animation_finished.is_connected(Callable(self, "_on_animation_finished")):
				#animation_player.animation_finished.connect(_on_animation_finished)
		#else:
			## Jeśli nie ma animacji, utwórz timer na czas trwania ataku
			#get_tree().create_timer(current_attack.attack_duration).timeout.connect(_on_attack_duration_timeout)
		#
		## Wywołaj metodę rozpoczęcia ataku
		#current_attack.start_attack(character)
		#
		## Wyemituj sygnał rozpoczęcia ataku
		#emit_signal("attack_started", current_attack.attack_name)
#
## Obsługuje zakończenie animacji
#func _on_animation_finished(anim_name):
	#if is_attacking and current_attack and anim_name == current_attack.animation_name:
		#finish_current_attack()
#
## Obsługuje timeout timera czasu trwania ataku
#func _on_attack_duration_timeout():
	#if is_attacking and current_attack:
		#finish_current_attack()
#
## Kończy aktualny atak
#func finish_current_attack():
	## Wywołaj metodę zakończenia ataku
	#current_attack.end_attack(character)
	#
	## Ustaw timer cooldown
	#attack_cooldown_timer = current_attack.cooldown
	#
	## Wyemituj sygnał zakończenia ataku
	#emit_signal("attack_ended", current_attack.attack_name)
	#
	## Zresetuj flagi
	#is_attacking = false
	#
	## Nie resetuj current_attack, aby można było sprawdzić możliwe następne ataki
#
## Czyści kolejkę ataków
#func clear_queue():
	#attack_queue.clear()
	#emit_signal("queue_cleared")
