extends TextureProgressBar

@onready var DASH_CD = self.owner.get_node('DashCD') as Timer
@onready var LABEL = self.owner.get_node('Camera/DashCD/CooldownLabel') as Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = (1 - (DASH_CD.time_left/DASH_CD.wait_time))*100
	if DASH_CD.is_stopped():
		LABEL.text = 'Ready'
	else:
		LABEL.text = ('%.2f' % DASH_CD.time_left)
	
