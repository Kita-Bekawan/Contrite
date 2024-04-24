extends Node

const SOUND_LASER = "laser"
const SOUND_DAMAGE = "damage"

var SOUNDS = {
	SOUND_LASER: preload("res://shooter/laser.wav"),
	SOUND_DAMAGE: preload("res://player/sounds/damage.wav")
}

func play_clip(player: AudioStreamPlayer2D, clip_key: String):
	if SOUNDS.has(clip_key) == false:
		return
	player.stream = SOUNDS[clip_key]
	player.play()
