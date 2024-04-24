extends Node

var scenes : Dictionary = { "Level4": "res://level/scenes/level_4.tscn",
							"Level4A": "res://level/scenes/level_4a.tscn",
							"Level4B": "res://level/scenes/level_4b.tscn",
							"Level4C": "res://level/scenes/level_4c_boss.tscn"}
							
func transition_to_scene(level: String):
	var scene_path: String = scenes.get(level)
	
	if scene_path != null:
		call_deferred("_change_scene", scene_path)

func _change_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
