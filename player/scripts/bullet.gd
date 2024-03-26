extends Area2D

@export var SPEED : float = 2.5
@export var MAX_TRAVEL_DISTANCE : float = 300
var init_global_position: Vector2
var direction = Vector2.ZERO

func _ready():
	init_global_position = global_position
	
func _physics_process(_delta):
	if direction != Vector2.ZERO:
		var velocity = direction * SPEED
		global_position += velocity
		
	if global_position.distance_to(init_global_position) > MAX_TRAVEL_DISTANCE:
		queue_free()
		
func set_direction(direction: Vector2):
	self.direction = direction

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
