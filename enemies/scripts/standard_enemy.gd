extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	move_and_slide()
	
	if velocity.x > 0:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

