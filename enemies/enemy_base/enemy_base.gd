extends CharacterBody2D

class_name EnemyBase

enum FACING { LEFT = -1, RIGHT = 1}

const OFF_SCREEN_KILL_ME: float = 1000.0

@export var default_facing: FACING = FACING.LEFT
@export var points: int = 1
@export var speed: float = 30.0
@export var health_point: int = 10

@onready var animation_tree = $AnimationTree
const HURT_REQUEST: String = "parameters/HurtOneShot/request"
const HURT_STATUS: String = "parameters/HurtOneShot/active"

var _gravity: float = 800.0
var _facing: FACING = default_facing
var _player_ref: Player
var _dying: bool = false
var _invincible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_ref = get_tree().get_nodes_in_group(GameManager.GROUP_PLAYER)[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	fallen_off()
	check_die()
	print(str(_invincible) + ' and ' + str(animation_tree[HURT_STATUS]))
	
func fallen_off() -> void:
	if global_position.y > OFF_SCREEN_KILL_ME:
		queue_free()

func check_die():
	if health_point <= 0:
		die()
		
func die():
	if _dying == true:
		return
	
	_dying = true
	SignalManager.on_enemy_hit.emit(points, global_position)
	ObjectMaker.create_simple_scene(global_position, ObjectMaker.SCENE_KEY.EXPLOSION)
	ObjectMaker.create_simple_scene(global_position, ObjectMaker.SCENE_KEY.PICKUP)
	set_physics_process(false)
	hide()
	queue_free()		

func hurt(damage: int):
	if !animation_tree[HURT_STATUS] and !_invincible:
		health_point -= damage
		set_invincible(true)
		#activate invis animation
		animation_tree[HURT_REQUEST] =\
			AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func set_invincible(v: bool) -> void:
	_invincible = v

func _on_visible_on_screen_notifier_2d_screen_entered():
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited():
	pass # Replace with function body.

func _on_hit_box_area_entered(area):
	if area.name == "BulletPlayer":
		hurt(area.get_damage())
	
