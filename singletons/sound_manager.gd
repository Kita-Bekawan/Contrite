extends Node

const SOUND_LASER = "laser"

var SOUNDS = {
	SOUND_LASER: preload("res://shooter/laser.wav")
}

func play_clip(player: AudioStreamPlayer2D, clip_key: String):
	if SOUNDS.has(clip_key) == false:
		return
	player.stream = SOUNDS[clip_key]
	player.play()
