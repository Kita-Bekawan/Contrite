extends Control

var dialog = [  # Use export for easy dialog editing
	"In a lush green land, there stood a tall tree,",
	"Providing shade for all beneath it.",
	"One was of a mother who, overwhelmed by life's struggles,",
	"left her child by the tree.",
	"Though she regretted it, she returned, but the child was gone.",
	"She waited, but in vain.",
	"Finally, she merged with the tree,",
	"Forever a part of its silent tale of love and loss."
]

var dialog_index = 0

func _ready():
	$RichTextLabel.visible_ratio = 0
	load_dialog()  

func _process(delta):
	if $RichTextLabel.visible_ratio == 1:
		load_dialog()

func load_dialog():
	if dialog_index < dialog.size():
		$RichTextLabel.visible_ratio = 0
		$RichTextLabel.bbcode_text = dialog[dialog_index]

		var tween = create_tween()
		var seconds = 0.075 * $RichTextLabel.get_total_character_count()
		tween.tween_property($RichTextLabel, "visible_ratio", 1, seconds)
		tween.play()
		dialog_index += 1
	else:
		queue_free()
		BGMManager.fade_out()
		SceneManager.transition_to_scene("Level0")
