extends LegacyMember

@onready var sliceScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/blade/slice.tscn")

@onready var pupil = $Pupil
@onready var marker = $Marker2D

var pos = Vector2(1189,345)

func _process(delta):
	if active:
		look_at_target(target, pupil, marker)
		position = position.move_toward(pos, delta * SPEED)
		
		attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			slice()

func slice():
	var leSlice = sliceScene.instantiate()
	leSlice.global_position.x = target.global_position.x
	mainScene.call_deferred("add_child", leSlice)
