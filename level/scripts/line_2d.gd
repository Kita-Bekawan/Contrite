extends Line2D

@onready var player := get_parent().get_node("Player")
var vec_start := Vector2.ZERO
var vec_fin := Vector2.ZERO

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_touch"):
		vec_start = get_global_mouse_position()
		vec_fin = vec_start
		points[0] = vec_start
	if Input.is_action_pressed("ui_touch"):
		vec_fin = get_global_mouse_position()
		points[1] = vec_fin
	if Input.is_action_just_released("ui_touch"):
		player.dir = ((vec_start - vec_fin)*2)#.normalized()*100)
