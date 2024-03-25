extends State


func enter():
	if transition_debug: print('Entering ' + self.name)
	
func exit():
	if transition_debug: print('Exiting ' + self.name)

func physics_update(_delta: float):
	
	$ShootingCD.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position, get_global_mouse_position())
