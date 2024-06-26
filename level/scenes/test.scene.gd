extends Node2D

@onready var heartsContainer = $CanvasLayer/HeartsContainer
@onready var player = $Player
@onready var playerState = player.get_node("StateMachine").get_node("PlayerState")

# Called when the node enters the scene tree for the first time.
func _ready():
	heartsContainer.setMaxHearts(playerState.maximumHealth)
	heartsContainer.updateHearts(playerState.currentHealth)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerState.get_node("PlayerHurt").healthChanged.connect(heartsContainer.updateHearts)
