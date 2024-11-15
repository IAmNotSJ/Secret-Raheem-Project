extends Camera2D

@export var offset_speed = 2
@export var dimensions = Vector2(4, 2)
@export var scroll_magnitude:int = 5
var offset_final:Vector2 = Vector2()

var can_scroll:bool = false

func _ready():
	_on_timer_timeout()

func _physics_process(delta):
	offset = lerp(offset, offset_final, offset_speed * delta)
	if offset == offset_final:
		_on_timer_timeout()

func give_random_vector2() -> Vector2:
	return Vector2(randf_range(-dimensions.x, dimensions.x), randf_range(-dimensions.y, dimensions.y))


func _on_timer_timeout() -> void:
	offset_final = give_random_vector2()
