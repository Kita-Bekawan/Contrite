extends CanvasLayer

@onready var pressedSfx = $ButtonPressedSFX

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameOverSFX.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_retry_button_pressed():
	pressedSfx.play()
	await pressedSfx.finished
	get_tree().change_scene_to_file("res://scenes/Dungeon.tscn")


func _on_quit_game_button_pressed():
	pressedSfx.play()
	await pressedSfx.finished
	get_tree().quit()


func _on_play_again_button_pressed():
	pressedSfx.play()
	await pressedSfx.finished
	get_tree().change_scene_to_file("res://scenes/Village.tscn")
