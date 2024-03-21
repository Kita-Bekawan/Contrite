extends Area2D

var vector : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(pos, tar):
	position = pos
	vector = tar-pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position += vector.normalized()


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
