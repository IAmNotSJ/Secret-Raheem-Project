extends Button

var cur_emotion = "neutral"

func _ready():
	for button in $emotions.get_children():
		button.pressed.connect(_on_button_pressed.bind(button))
	$emotions.visible = false

func _on_button_pressed(button):
	var emotion:String = button.name
	cur_emotion = emotion
	icon = button.icon
	$emotions.visible = false


func _on_pressed() -> void:
	if $emotions.visible == true:
		$emotions.visible = false
	else:
		$emotions.visible = true
