extends Boss2State
class_name Boss2Idle

func enter():
	if chara.dead == false:
		super.enter()
		owner.set_physics_process(true)
		animation.play('idle')
		chara.speed = 0

func physics_update(delta: float): 
	transition()


#func transition():
	#if player_entered == true:
		#state_transition_signal.emit(self, "Boss2Walk")
	#

#func _on_player_detection_body_entered(body):
	#if body.name == "Player":
		#player_entered = true
		#print(player_entered)

#func _on_player_detection_body_exited(body):
	#if body.name == "Player":
		#player_entered = false
		#print(player_entered)
