extends Sprite2D


func _ready():
	Overworld.hour_passed.connect(_on_hour_passed)
	if Overworld.get_current_hour() >= 18 or Overworld.get_current_hour() <= 4:
		$animationplayer.play('on')
		$Moths.visible = true
	else:
		$animationplayer.play('off')
		$Moths.visible = false



func _on_hour_passed():
	if Overworld.get_current_hour() >= 18:
		$animationplayer.play('on')
		$Moths.visible = true
	if Overworld.get_current_hour() > 4 and Overworld.get_current_hour() < 18:
		$animationplayer.play('off')
		$Moths.visible = false
