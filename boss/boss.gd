extends Node2D

const TRIGGER_CONDITION: String = "parameters/conditions/on_trigger"
const HIT_CONDITION: String = "parameters/conditions/on_hit"

@onready var animation_tree = $AnimationTree
@onready var visual = $Visual
@onready var hit_box = $Visual/HitBox

@export var lives: int = 2
@export var points: int = 5

var _invincible: bool = false
var _has_triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func tween_hit() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(visual, "position", Vector2.ZERO, 1.0)

func reduce_lives() -> void:
	lives -= 1
	print("reduce_lives:", lives)
	if lives <= 0:
		SignalManager.on_boss_killed.emit(points)
		BGMManager.fade_out()
		print("dead")
		set_process(false)
		queue_free()

func set_invincible(v: bool) -> void:
	print("set_invincible:", v)
	_invincible = v
	animation_tree[HIT_CONDITION] = v

func take_damage() -> void:
	
	if _has_triggered == false:
		return
	
	if _invincible == true:
		return
	
	set_invincible(true)
	tween_hit()
	reduce_lives()

func _on_trigger_area_entered(area):
	if animation_tree[TRIGGER_CONDITION] == false:
		animation_tree[TRIGGER_CONDITION] = true
		_has_triggered = true
		hit_box.collision_layer = 4
	if !BGMManager.isPlaying:
		BGMManager.bgm = preload("res://audio/Battle on horizon.mp3")
		BGMManager.bgm_player.stream = BGMManager.bgm
		BGMManager.bgm_player.volume_db = -12.5
		BGMManager.play_bgm()
func _on_hit_box_area_entered(area):
	take_damage()
