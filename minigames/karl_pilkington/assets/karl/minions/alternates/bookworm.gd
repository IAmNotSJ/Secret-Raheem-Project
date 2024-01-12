extends Alternate

enum {
	IDLE,
	ATTACK
}
var state = IDLE

func _ready():
	if targetArray != []:
		targetArray.shuffle()
		target = targetArray[0]
	
func _process(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, delta * 20)
			move_and_slide()
		ATTACK:
			velocity = velocity.move_toward(target.position, delta * 20)
