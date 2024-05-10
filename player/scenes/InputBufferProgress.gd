extends TextureProgressBar

@onready var INPUT_BUFFER = self.owner.get_node('InputBuffer') as Timer
@onready var LABEL = self.owner.get_node('Camera/InputBuffer/CooldownLabel') as Label
@onready var PLAYER_STATE = self.owner.get_node('StateMachine/PlayerState') as Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = (1 - (INPUT_BUFFER.time_left/INPUT_BUFFER.wait_time))*100
	if INPUT_BUFFER.is_stopped():
		LABEL.text = 'Ready'
	else:
		LABEL.text = ('%.2f' % INPUT_BUFFER.time_left)
	
