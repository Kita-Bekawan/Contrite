extends Area2D

signal vector_created(vector)

@export var maximum_length := 200

var touch_down := false
var position_start := Vector2.ZERO
var position_end := Vector2.ZERO

var vector := Vector2.ZERO
var vector_adjustment := Vector2(200,200)


func _draw() -> void:
	draw_line((position_start - global_position - vector_adjustment), 
		(position_end - global_position -  vector_adjustment), 
		Color.BLUE, 
		8)
	
	draw_line((position_start - global_position - vector_adjustment), 
		(position_start - global_position + vector - vector_adjustment), 
		Color.RED, 
		16)


func _reset() -> void:
	position_start = Vector2.ZERO
	position_end = Vector2.ZERO
	vector = Vector2.ZERO
	
	queue_redraw()
	

func _input(event) -> void:
	if event.is_action_pressed("ui_touch"):
		touch_down = true
		position_start = event.position
	
	if event.is_action_released("ui_touch"):
		touch_down = false
		emit_signal("vector_created", vector)
		_reset()
	
	if not touch_down:
		return
	
	if event is InputEventMouseMotion:
		position_end = event.position
		if get_overlapping_bodies():
			vector = -(position_end - position_start).limit_length(maximum_length)
		
		queue_redraw()
