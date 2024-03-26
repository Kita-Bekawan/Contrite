extends Area2D

@export var speed : float = 2.5
var direction = Vector2.ZERO

func _physics_process(_delta):
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity
		
func set_direction(direction: Vector2):
	self.direction = direction

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
