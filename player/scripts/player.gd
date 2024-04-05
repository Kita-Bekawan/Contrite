extends CharacterBody2D

func _ready():
	pass
		
func start():
	pass

func _physics_process(delta):
	move_and_slide()

func _on_catapult_vector_created(vector):
	var stateMachine = $StateMachine
	var currentState:State = stateMachine.current_state
	velocity += vector * 10
	move_and_slide()
	currentState.state_transition_signal.emit(currentState, 'PlayerFall')
