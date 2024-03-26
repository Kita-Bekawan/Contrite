extends PlayerShoot
class_name PlayerShootJump

@export var JUMP_SPEED = 800
@export var MIN_JUMP_HEIGHT = 150
var starting_height: float
var release_early: bool

func enter():
	chara.velocity.y = -JUMP_SPEED #init speed

func physics_update(_delta):
	push_off_ledge()
	super.physics_update(_delta)
	var relative_position = starting_height - chara.position.y
	if Input.is_action_just_released('jump') and relative_position < MIN_JUMP_HEIGHT:
		release_early = true
	
	if release_early and relative_position > MIN_JUMP_HEIGHT:
		chara.velocity.y = lerp(chara.velocity.y, 0.0, 0.5)
		if chara.velocity.y < 0:
			release_early = false


func push_off_ledge() -> void:
	var left_inner := hitbox.get_node('LeftInnerRayCast') as RayCast2D
	var left_outer := hitbox.get_node('LeftOuterRayCast') as RayCast2D
	var right_inner := hitbox.get_node('RightInnerRayCast') as RayCast2D
	var right_outer := hitbox.get_node('RightOuterRayCast') as RayCast2D
	
	var left_colliding_body = left_outer.get_collider()
	var right_colliding_body = right_outer.get_collider()
	
	if left_colliding_body and !left_inner.is_colliding()\
	 and !right_inner.is_colliding() and !right_outer.is_colliding()\
	  and get_modified_object_name(left_colliding_body) == 'TileMap':
		print('geser kiri')
		chara.position.x += 8
		can_push_off = false
	if right_colliding_body and !right_inner.is_colliding()\
	 and !left_inner.is_colliding() and !left_outer.is_colliding()\
	  and get_modified_object_name(right_colliding_body) == 'TileMap':
		print('geser kanan')
		print(right_outer.get_collider())
		chara.position.x -= 8
		can_push_off = false
		
func get_modified_object_name(obj: Object) -> String:
	if obj:
		var name = obj.name
		return name.left(\
		 name.length() - name.find(':'))
	else:
		return ''
