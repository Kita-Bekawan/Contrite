extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print_debug(body)
	if body.name == "Player":
		body.get_node("StateMachine").get_node("PlayerState").set_checkpoint_position(position)
