extends Boss2State
class_name Boss2Walk


func enter():
	super.enter()
	owner.set_physics_process(true)
	animation.play('walk')
	if chara.rage == true:
		print("rage speed")
		chara.speed = chara.RAGE_SPEED
	else:
		print("default speed")
		chara.speed = chara.DEFAULT_SPEED

#func physics_update(_delta: float): 
	#transition()
	
func transition():
	var distance = owner.direction.length()
	if distance <= 75:
		state_transition_signal.emit(self, "Boss2Attack")
	#if player_entered == false:
		#state_transition_signal.emit(self, "Boss2Idle")
	

#func _on_player_detection_body_exited(body):
	#if body.name == "Player":
		#player_entered = false
		#print(player_entered)
