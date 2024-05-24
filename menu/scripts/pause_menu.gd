extends Control

func _ready():
	print("Scene ready, unpausing game.")
	get_tree().paused = false
	self.visible = false
	print("Initial paused state: ", get_tree().paused)

func resume():
	print("Resuming game.")
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	self.visible = false
	print("Paused state after resume: ", get_tree().paused)

func pause():
	print("Pausing game.")
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	self.visible = true
	print("Paused state after pause: ", get_tree().paused)

func testEsc():
	if Input.is_action_just_pressed("ui_cancel"):
		print("ESC pressed. Current paused state: ", get_tree().paused)
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_resume_pressed():
	resume()

func _on_quit_pressed():
	get_tree().quit()

func _process(delta):
	testEsc()

func _on_main_menu_pressed():
	resume()
	BGMManager.fade_out()
	get_tree().change_scene_to_file("res://menu/scenes/start_menu.tscn")
