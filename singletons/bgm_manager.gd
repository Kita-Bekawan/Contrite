extends Node
var bgm_player = null
var bgm = null
var isPlaying = false

# Called when the node enters the scene tree for the first time.
func _ready():
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	
func play_bgm():
	if bgm_player and bgm and not isPlaying:
		bgm_player.play()
		isPlaying = true

func fade_out():
	if bgm_player and isPlaying:
		var fade_duration = 2.0
		var start_vol = bgm_player.volume_db
		var end_vol = -80.0  
		var current_time = 0.0
		
		while current_time < fade_duration:
			var t = current_time / fade_duration
			bgm_player.volume_db = lerp(start_vol, end_vol, t)
			await get_tree().process_frame
			current_time += get_process_delta_time()
		
		bgm_player.stop()
		bgm_player.volume_db = start_vol
		isPlaying = false
func _process(delta):
	pass
