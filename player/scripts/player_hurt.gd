extends PlayerState
class_name PlayerHurt
signal healthChanged

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hitbox_area_entered(area):
	if area.name == "Catapult":
		currentHealth -= 1
		if currentHealth < 1:
			currentHealth = maximumHealth
		healthChanged.emit(currentHealth)
