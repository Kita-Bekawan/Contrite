extends Boss2State
class_name Boss2Attack

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func enter():
	super.enter()
	chara.attack = true
	#owner.set_physics_process(true)
	animation.play('attack')
	chara.speed = 0
	await animation.animation_finished
	chara.attack = false
	chara.finished_attacking()

func physics_update(delta: float): 
	transition()
