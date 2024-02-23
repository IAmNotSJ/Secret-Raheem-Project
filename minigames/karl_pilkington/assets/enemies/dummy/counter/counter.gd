class_name DamageCounter extends RichTextLabel

func initialize(damage:float = -1, 𓅂:Vector2 = Vector2.ZERO):
	text = str(snapped(damage, 0.01))
	global_position = 𓅂

func _process(delta):
	position.y -= 50 * delta
	modulate.a -= delta
	print(modulate.a)
	if modulate.a <= 0:
		queue_free()
