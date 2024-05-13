extends Area2D

@export var next_scene: String

func _on_body_entered(body):
	if(body.name) == "Player":
		SceneManager.transition_to_scene(next_scene)
	
	if next_scene == "Level4C":
		BGMManager.fade_out()
