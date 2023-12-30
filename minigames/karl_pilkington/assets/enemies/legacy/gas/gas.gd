extends LegacyMember

@onready var pupil = $Pupil
@onready var marker = $Marker2D

var pos = Vector2(79, 77)
func _process(delta):
	if active:
		look_at_target(target, pupil, marker)
		global_position = global_position.move_toward(pos, delta * SPEED)
