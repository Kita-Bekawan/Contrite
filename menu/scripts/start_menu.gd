extends Node

@onready var pressedSfx = $ButtonPressedSFX

# Called when the node enters the scene tree for the first time.
func _ready():
	if !BGMManager.isPlaying:
		BGMManager.bgm = preload("res://audio/Lost in the Forest.mp3")
		BGMManager.bgm_player.stream = BGMManager.bgm
		BGMManager.bgm_player.volume_db = -12.5
		BGMManager.play_bgm()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_button_pressed():
	pressedSfx.play()
	BGMManager.fade_out()
	await pressedSfx.finished
	SceneManager.transition_to_scene("cutscene")


func _on_quit_button_pressed():
	pressedSfx.play()
	await pressedSfx.finished
	get_tree().quit()
