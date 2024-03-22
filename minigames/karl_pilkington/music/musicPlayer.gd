extends AudioStreamPlayer

func _on_finished():
	play()

func speed_up(speed:float):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "pitch_scale", speed, 0.2)
