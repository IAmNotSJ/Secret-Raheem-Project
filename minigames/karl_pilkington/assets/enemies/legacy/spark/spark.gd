extends LegacyMember

@onready var pupil = $Pupil
@onready var marker = $Marker2D

@onready var boltScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/spark/mark.tscn")

var pos = Vector2(1209, 605)
func _process(delta):
	if active:
		global_position = global_position.move_toward(pos, SPEED * delta)
		look_at_target(target, pupil, marker)
		if mainScene.boosted:
			attackTimer -= delta * 2.5
		else:
			attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			spawn_bolt()

func spawn_bolt():
	var spark = boltScene.instantiate()
	spark.global_position = target.global_position
	spark.target = target
	mainScene.call_deferred("add_child", spark)
