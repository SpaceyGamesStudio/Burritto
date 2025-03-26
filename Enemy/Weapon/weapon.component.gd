extends Node3D
class_name WeaponComponent

@export var skeleton: Skeleton3D;
@export var animation_player: AnimationPlayer

@onready var hitbox: Area3D  = %Hitbox
@onready var hit_range: Area3D = %HitRange

@onready var hand_bone_idx: int = skeleton.find_bone('hand.l')

signal player_entered_hit_range
signal player_exited_hit_range
signal player_hit

var player_in_range = false

func _ready():
	hitbox.area_entered.connect(on_hit)
	hit_range.area_entered.connect(_on_hit_range_enter)
	hit_range.area_exited.connect(_on_hit_range_exit)

	hitbox.monitoring = false
	pass

func _physics_process(delta: float) -> void:
	if(player_in_range):
		hitbox.transform = skeleton.get_bone_global_pose(hand_bone_idx)

func on_hit(area: Area3D):
	if(!player_in_range):
		return

	if(!animation_player.is_playing()):
		return

	var player_exited_range = !is_player_in_area(area)

	if(player_exited_range):
		return

	player_hit.emit()

func is_player(body):
	return body is Player

func is_player_in_area(area: Area3D):
	return area.get_overlapping_bodies().find_custom(is_player.bind()) != -1

func _on_hit_range_enter(area: Area3D):
	player_in_range = is_player_in_area(area)

	if (!player_in_range):
		return
	
	hitbox.monitoring = true
	player_entered_hit_range.emit()

func _on_hit_range_exit(area: Area3D):
	if (!player_in_range):
		return

	var player_exited_range = !is_player_in_area(area)

	if(player_exited_range):
		return

	hitbox.monitoring = false
	player_exited_hit_range.emit()
