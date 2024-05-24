extends RayCast2D

var is_casting: set = set_is_casting
var tween 

# Called when the node enters the scene tree for the first time.
func _ready():
	is_casting = false
	tween = create_tween()

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		self.is_casting = event.pressed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var cast_point = Vector2.ZERO
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
	$Line2D.points[1] = cast_point

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	set_physics_process(is_casting)
	
	if is_casting:
		appear()
	else:
		disappear()
		
func appear() -> void:
	tween.stop()
	tween.tween_property($Line2D, "width", 10.0, 0.2)
	tween.play()
	
func disappear() -> void:
	tween.stop()
	tween.tween_property($Line2D, "width", 0, 0.2)
	tween.play()
