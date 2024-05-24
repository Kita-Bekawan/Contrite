extends Node

@onready var pressedSfx = $ButtonPressedSFX

# Called when the node enters the scene tree for the first time.
func _ready():
	$BGM.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_button_pressed():
	pressedSfx.play()
	await pressedSfx.finished
	SceneManager.transition_to_scene("Level0")


func _on_quit_button_pressed():
	pressedSfx.play()
	await pressedSfx.finished
	get_tree().quit()
