extends Node

var _score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_boss_killed.connect(on_boss_killed)
	SignalManager.on_pickup_hit.connect(on_pickup_hit)
	SignalManager.on_enemy_hit.connect(on_enemy_hit)

func on_boss_killed(p: int) -> void:
	update_score(p)

func on_pickup_hit(p: int) -> void:
	update_score(p)

func on_enemy_hit(p: int, _v: Vector2) -> void:
	update_score(p)

func update_score(points: int) -> void:
	_score += points
	SignalManager.on_score_updated.emit()
	
func get_score() -> int:
	return _score

func reset_score() -> void:
	_score = 0
