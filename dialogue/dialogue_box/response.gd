extends TextureButton

func changeText(text:String):
	$RichTextLabel.text = text

func _process(_delta):
	if !has_focus():
		modulate.a = 0.5
	else:
		modulate.a = 1
