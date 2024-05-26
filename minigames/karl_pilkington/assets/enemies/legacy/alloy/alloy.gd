extends LegacyMember

@onready var pillScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/alloy/daPill.tscn")

@onready var pupil = $Node2D/Pupil
@onready var marker = $Node2D/Marker2D

var pos = Vector2(80, 334)
func _process(delta):
	if active:
		global_position = global_position.move_toward(pos, SPEED * delta)
		look_at_target(target, pupil, marker)
		attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			$AnimationPlayer.play('jump')
			spawn_pill()

func spawn_pill():
	var pill = pillScene.instantiate()
	var daAngle = target.global_position - global_position
	pill.angle = rad_to_deg(daAngle.angle())
	pill.global_position = pupil.global_position
	mainScene.call_deferred("add_child", pill)
