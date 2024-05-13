extends Area2D

@export var dialogName: String
@onready var player = get_node("../Player")
func _ready():
	pass # Replace with function body.


func _input(event):
	if Dialogic.current_timeline != null:
		return
	if event is InputEventKey and event.keycode == KEY_E and event.pressed and player._active:
		var dialog = Dialogic.start(dialogName)
		get_viewport().set_input_as_handled()
		
		
