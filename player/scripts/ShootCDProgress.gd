extends TextureProgressBar

@onready var ShootCD = self.owner.get_node('ShootCD') as Timer
@onready var LABEL = self.owner.get_node('Camera/ShootCD/CooldownLabel') as Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = (1 - (ShootCD.time_left/ShootCD.wait_time))*100
	if ShootCD.is_stopped():
		LABEL.text = 'Ready'
	else:
		LABEL.text = ('%.2f' % ShootCD.time_left)
	
