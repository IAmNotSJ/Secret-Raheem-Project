extends LegacyMember
@onready var pupil = $Pupil
@onready var marker = $Marker2D

var pos = Vector2(1216, 75)

func _process(delta):
	if active:
		mainScene.boosted = true
		look_at_target(target, pupil, marker)
		global_position = global_position.move_toward(pos, delta * SPEED)

func change_active():
	mainScene.music.speed_up(1.2)
	super()

func die():
	mainScene.boosted = false
	mainScene.music.speed_up(1)
	super()
