extends Button

var cur_emotion = "neutral"

func _ready():
	for button in $emotions.get_children():
		button.pressed.connect(_on_button_pressed.bind(button))
	$emotions.visible = false

func _on_button_pressed(button):
	var emotion:String
	match button.text:
		"o_o":
			emotion = "wut"
		":)":
			emotion = "happy"
		":[":
			emotion = "pout"
		":o":
			emotion = "shocked"
		"'_'":
			emotion = "neutral"
		"|:)":
			emotion = "smug"
		":(":
			emotion = "sad"
		"?_?":
			emotion = "confused"
		">:(":
			emotion = "angry"
	cur_emotion = emotion
	text = button.text
	$emotions.visible = false


func _on_pressed() -> void:
	if $emotions.visible == true:
		$emotions.visible = false
	else:
		$emotions.visible = true
