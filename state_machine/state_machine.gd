extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_child(0).get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition_signal.connect(change_state)	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func change_state(source_state: State, new_state_name: String) -> void:
	if source_state != current_state:
		print("current_state ", current_state.name)
		print('Invalid state transition from: "' + source_state.name + '" to: ' + new_state_name)
		return
		
	var new_state = states.get(new_state_name.to_lower())
	
	if !new_state:
		print('New state "' + new_state_name + '" doesn\'t exist')
		return
	
	if current_state:
		current_state.exit()
	new_state.enter()
	
	current_state = new_state
