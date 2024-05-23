extends EnemyBase

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player_detector = $PlayerDetector
@onready var shooter = $Shooter
@onready var left_detector = $TerrainDetector/Left
@onready var right_detector = $TerrainDetector/Right
@onready var up_detector = $TerrainDetector/Up
@onready var down_detector = $TerrainDetector/Down
@onready var reorienting_timer = $ReorientingTimer

const FLY_SPEED: Vector2 = Vector2(35, 15)

var _fly_direction: Vector2 = Vector2.ZERO
var _reorienting: bool = false

@onready var direction_timer = $DirectionTimer
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super._physics_process(delta)
	velocity = _fly_direction
	move_and_slide()
	shoot()
	check_terrain()
	

func check_terrain() -> void:
	# random movement ketika deket terrain
	var left_collide = left_detector.is_colliding() == true \
		and left_detector.get_collider().name != "Player"
	var right_collide = right_detector.is_colliding() == true \
		and right_detector.get_collider().name != "Player"
	var up_collide = up_detector.is_colliding() == true \
		and up_detector.get_collider().name != "Player"
	var down_collide = down_detector.is_colliding() == true \
		and down_detector.get_collider().name != "Player"
	var x_dir = 0
	var y_dir = 0
	var rand_hori = true
	var rand_vert = true
	if left_collide or right_collide or up_collide or down_collide:
		if left_collide:
			x_dir += 1
			rand_hori = false
		if right_collide:
			x_dir -= 1
			rand_hori = false
		if up_collide:
			y_dir += 1
			rand_vert = false
		if down_collide:
			y_dir -= 1
			rand_vert = false
		x_dir = randi_range(-1, 1) if rand_hori else x_dir 
		y_dir = randi_range(-1, 1) if rand_vert else y_dir 
		set_and_flip(false, x_dir, y_dir)
		reorienting_timer.wait_time = randf_range(1, 4)
		_reorienting = true
		reorienting_timer.start()
	
func shoot() -> void:
	if player_detector.is_colliding() == true:
		shooter.shoot(
			global_position.direction_to(_player_ref.global_position)
		)

func set_and_flip(to_player: bool = true, x_dir: int = 0, y_dir: int = 0) -> void:
	if to_player:
		x_dir = sign(_player_ref.global_position.x - global_position.x)
		y_dir = sign (_player_ref.global_position.y - global_position.y)
	if x_dir > 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	_fly_direction = Vector2(x_dir, y_dir) * FLY_SPEED

func fly_to_player() -> void:
	set_and_flip(true)
	direction_timer.start()

func _on_visible_on_screen_notifier_2d_screen_entered():
	animated_sprite_2d.play("fly")
	fly_to_player()

func _on_direction_timer_timeout():
	if !_reorienting:
		fly_to_player()

func _on_reorienting_timer_timeout():
	_reorienting = false
