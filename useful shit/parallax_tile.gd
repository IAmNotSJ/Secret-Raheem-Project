@tool
class_name ParallaxTile extends TextureRect

@export var active:bool = false
@export var speed:Vector2 = Vector2(50, 50)

@export var crossingPoint:float = 0

func _ready():
	active = true
	if crossingPoint == 0:
		if speed.x < 0:
			crossingPoint = texture.get_width() * 4
		else:
			crossingPoint = -texture.get_width() * 4
func _process(delta):
	if active:
		position += speed * delta
		if speed.x < 0:
			if position.x <= crossingPoint:
				if speed.x < 0:
					position.x += (texture.get_width() * 2)
				if speed.y < 0:
					position.y += (texture.get_width() * 2)
		else:
			if position.x >= crossingPoint:
				if speed.x > 0:
					position.x -= (texture.get_width() * 2)
				if speed.y > 0:
					position.y -= (texture.get_width()* 2)
