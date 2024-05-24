extends Control

@onready var hb_hearts = $MC/HB/HB_Hearts
@onready var score_label = $MC/HB/ScoreLabel

var _hearts: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_hearts = hb_hearts.get_children()
	score_label.text = str(ScoreManager.get_score()).lpad(4, "0")
	SignalManager.on_player_hit.connect(on_player_hit)
	SignalManager.on_score_updated.connect(on_score_updated)

func on_score_updated() -> void:
	score_label.text = str(ScoreManager.get_score()).lpad(4, "0")
	
func on_player_hit(lives: int) -> void:
	for life in range(_hearts.size()):
		_hearts[life].visible = lives > life
