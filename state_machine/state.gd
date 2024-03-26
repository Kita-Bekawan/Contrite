extends Node
class_name State

signal state_transition_signal
@onready var chara: CharacterBody2D = self.owner
@onready var sprite: AnimatedSprite2D = chara.get_node('Sprite')
@onready var hitbox: CollisionShape2D = chara.get_node('Hitbox')
@export var bullet : PackedScene

@onready var DASH_CD: Timer = chara.get_node('DashCD')
@onready var SHOOT_CD: Timer = chara.get_node('ShootCD')
@onready var COYOTE_TIMER: Timer = chara.get_node('CoyoteTimer')
@onready var INPUT_BUFFER: Timer = chara.get_node('InputBuffer')


var can_push_off = false
var last_input = null
var transition_debug = true
var velocity_debug = false

func enter():
	if transition_debug: print('Entering ' + self.name)
	
func exit():
	if transition_debug: print('Exiting ' + self.name)
	
func update(_delta: float):
	if velocity_debug: print(chara.velocity)
	pass
	
func physics_update(_delta: float):
	pass

