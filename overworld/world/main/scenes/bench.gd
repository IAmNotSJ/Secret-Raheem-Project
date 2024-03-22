extends Sprite2D

@export var seat1occupied:bool = false
@export var seat2occupied:bool = false

func _ready():
	if seat1occupied:
		$Seat1Interaction.queue_free()
	if seat2occupied:
		print('huh')
		$Seat2Interaction.queue_free()

func interact(body):
	body.animationPlayer.play('jump')
	body.position = Vector2(-461, 210)
	body.in_bench = true
