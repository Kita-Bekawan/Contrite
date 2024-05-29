extends Node

const SOUND_LASER = "laser"
const SOUND_DAMAGE = "damage"
const SOUND_HEAL = "heal"

var SOUNDS = {
	SOUND_LASER: preload("res://shooter/laser.wav"),
	SOUND_DAMAGE: preload("res://player/sounds/damage.wav"),
	SOUND_HEAL: preload("res://audio/heal-sfx.mp3")
}

func play_clip(player: AudioStreamPlayer2D, clip_key: String):
	if SOUNDS.has(clip_key) == false:
		return
	player.stream = SOUNDS[clip_key]
	player.play()
