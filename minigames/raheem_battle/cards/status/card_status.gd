extends Label

@onready var ui = get_parent()

const SPEED:int = 30
const FADE_SPEED:float = 0.5

func _process(delta):
	modulate.a -= FADE_SPEED * delta
	position.y -= SPEED * delta
	if modulate.a <= 0:
		#ui.statuses.erase(text)
		queue_free()
