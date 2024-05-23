extends Area2D

var _direction: Vector2 = Vector2.RIGHT
var _life_span: float = 20.0
var _life_time: float= 0.0
var _damage: int= 1

@onready var animation_tree = $AnimationTree
const HIT_CONDITION: String = "parameters/conditions/on_hit"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_expired(delta)
	if !animation_tree[HIT_CONDITION]: #kalau dah explode, posisi berhenti
		position += _direction * delta
	
func setup(dir: Vector2, life_span: float, speed: float, damage: int) -> void:
	_direction = dir.normalized() * speed
	_life_span = life_span
	_damage = damage

func check_expired(delta: float) -> void:
	_life_time += delta
	if _life_time > _life_span and !animation_tree[HIT_CONDITION]:
		queue_free()

func get_damage() -> int:
	return _damage

func _on_area_entered(area):
	animation_tree[HIT_CONDITION] = true


func _on_body_entered(body): #buat deteksi tilemap, dia body bukan area
	animation_tree[HIT_CONDITION] = true
