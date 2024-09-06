extends CanvasGroup

var go:bool = false
var timer:float = 1

func _ready():
	$AnimationPlayer.play('fade')

func move(amount):
	$counter.text = "+" + str(amount)
	go = true

func _process(delta):
	if (go):
		position.y -= 100 * delta
		scale = scale.lerp(Vector2(1, 1), delta)
		timer -= delta
		if (timer <= 0):
			queue_free()
