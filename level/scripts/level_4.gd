extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if !BGMManager.isPlaying:
		BGMManager.bgm = preload("res://audio/Michibiki no Tabibito.mp3")
		BGMManager.bgm_player.stream = BGMManager.bgm
		BGMManager.bgm_player.volume_db = -12.5
		BGMManager.play_bgm()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
