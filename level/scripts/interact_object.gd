extends Area2D

@onready var player = get_node("../Player")
func _ready():
	pass # Replace with function body.


func _input(event):
	if Dialogic.current_timeline != null:
		return
	if event is InputEventKey and event.keycode == KEY_E and event.pressed and player._active:
		if player._interactWith == "Druid":
			var dialog = Dialogic.start("luhur")
		if player._interactWith == "Mother":
			var dialog = Dialogic.start("saraswati")
		get_viewport().set_input_as_handled()
		
