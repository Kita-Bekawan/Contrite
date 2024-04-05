extends Node
class_name State

signal state_transition_signal

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func transition() -> void: 
	pass

func transition_with_param(parameter: float) -> void: 
	pass
