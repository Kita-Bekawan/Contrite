extends State
class_name Boss2State

@onready var chara: CharacterBody2D = self.owner
@onready var sprite: Sprite2D = chara.get_node('Sprite')
@onready var animation: AnimationPlayer = chara.get_node('AnimationPlayer')
@onready var debuglabel: Label = chara.get_node('debug')
@onready var player_entered : bool = false:
	set(value):
		player_entered = value

#func _ready():
	#set_physics_process(false)
#
func enter() -> void:
	set_physics_process(true)
#
#func transition():
	#pass
#
#
func _physics_process(delta):
	transition()
	debuglabel.text = name
	
