extends CharacterBody2D

@onready var player = get_parent().find_child("Player")
@onready var sprite = $Sprite2D
@onready var idle_state: Node = get_node('StateMachine/Boss2State/Boss2Idle')
@onready var walk_state: Node = get_node("StateMachine/Boss2State/Boss2Walk")
@onready var attack_state: Node = get_node("StateMachine/Boss2State/Boss2Attack")
@onready var rage_state: Node = get_node("StateMachine/Boss2State/Boss2Rage")
@onready var state_machine: Node = get_node("StateMachine")
@onready var deflect_area: Area2D = get_node("Deflect")
@onready var melee_area: Area2D = get_node("Melee")
@onready var shooter: Node2D = get_node("Shooter")
@onready var hit_flash_anim: AnimationPlayer = get_node("HitFlash")

@onready var player_in_range: bool = false
@onready var attack: bool = false
@onready var speed = 100
@onready var DEFAULT_SPEED = 100
@onready var RAGE_SPEED = 200

@onready var rage: bool  = false
@onready var rage_finish: bool = false
var rng = RandomNumberGenerator.new()
var rand_int: int
var direction : Vector2

@export var lives: int = 100
@export var rage_lives: int = 50
@export var points: int = 5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	set_physics_process(false)

func _process(delta):
	direction = player.position - position
	if direction.x < 0 && attack == false:
		sprite.flip_h = true
		melee_area.position.x = -96.5
		deflect_area.position.x = -340
	elif direction.x > 0 && attack == false:
		sprite.flip_h = false
		melee_area.position.x = 0
		deflect_area.position.x = 0
func _physics_process(delta):
	velocity.x = direction.normalized().x * speed
	move_and_collide(delta*velocity)
	
	
func _on_player_detection_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		if state_machine.current_state == idle_state:
			state_machine.change_state(idle_state, "Boss2Walk")

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		state_machine.change_state(walk_state, "Boss2Idle")

func finished_attacking():
	print("player_in_range", player_in_range)
	if(player_in_range == true):
		state_machine.change_state(attack_state, "Boss2Walk")
	else:
		state_machine.change_state(attack_state, "Boss2Idle")

func finished_rage():
	print("player_in_range", player_in_range)
	if(player_in_range == true):
		state_machine.change_state(rage_state, "Boss2Walk")
	else:
		state_machine.change_state(rage_state, "Boss2Idle")

func rage_activation():
	rage = true
	print("rage activated")
	if state_machine.current_state == attack_state:
		state_machine.change_state(attack_state, "Boss2Rage")
	elif state_machine.current_state == walk_state:
		state_machine.change_state(walk_state, "Boss2Rage")
	elif state_machine.current_state == idle_state:
		state_machine.change_state(idle_state, "Boss2Rage")

func reduce_lives() -> void:
	lives -= 1
	hit_flash_anim.play("hit_flash")
	print("reduce_lives:", lives)
	if lives == 50:
		rage_activation()
	if lives <= 0:
		SignalManager.on_boss_killed.emit(points)
		print("dead")
		set_process(false)
		queue_free()
			

func _on_melee_body_entered(body):
	if body.name == "Player":
		player._lives -= 1
		player.reduce_lives()
		print(player._lives)


func _on_hit_box_area_entered(area):
	reduce_lives()

func _on_deflect_area_entered(area):
	rand_int = rng.randi_range(0,10)
	if rage == true:
		print("DEFLECT!")
		state_machine.change_state(walk_state, "Boss2Attack")


func shoot() -> void:
	shooter.additional_offset = -24.0
	if sprite.flip_h == true:
		shooter.shoot(Vector2(Vector2.LEFT))
	else:
		shooter.shoot(Vector2.RIGHT)


func _on_melee_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	shoot()
