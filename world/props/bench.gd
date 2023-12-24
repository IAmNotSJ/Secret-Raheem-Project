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
	if $Seat1Interaction.has_overlapping_areas():
		print("PENIS!")
		body.global_position = $Seat.global_position
	elif $Seat2Interaction.has_overlapping_areas():
		body.global_position = $Seat2.global_position
