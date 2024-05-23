extends Boss2State
class_name Boss2Rage

func enter():
	super.enter()
	owner.set_physics_process(true)
	chara.speed = 0
	animation.play('rage')
	await animation.animation_finished
	chara.finished_rage()
	

func physics_update(delta: float): 
	transition()
