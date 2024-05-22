extends Area2D

signal vector_created(vector)

@export var maximum_length := 200

var touch_down := false
var position_start := Vector2.ZERO
var position_end := Vector2.ZERO

var vector := Vector2.ZERO


func _draw() -> void:
	draw_line(position_start, position_end, Color.BURLYWOOD, 8)
	draw_line(position_start, position_start + vector, Color.SADDLE_BROWN, 16)


func _reset() -> void:
	position_start = Vector2.ZERO
	position_end = Vector2.ZERO
	vector = Vector2.ZERO
	
	queue_redraw()
	

func _input(event) -> void:
	if event.is_action_pressed("ui_touch"):
		touch_down = true
		position_start = get_local_mouse_position()
	
	if event.is_action_released("ui_touch"):
		touch_down = false
		position_end = get_local_mouse_position()
		emit_signal("vector_created", vector)
		_reset()
	
	if not touch_down:
		return
	
	if event is InputEventMouseMotion:
		position_end = get_local_mouse_position()
		if get_overlapping_bodies():
			vector = -(position_end - position_start).limit_length(maximum_length)
			queue_redraw()
		
