extends LegacyMember

@onready var pupil = $Pupil
@onready var marker = $Marker2D

@onready var fireScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/flame/fire.tscn")

var pos = Vector2(1011, 100)

func _process(delta):
	if active:
		look_at_target(target, pupil, marker)
		
		attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			if mainScene.boosted:
				spawn_fire(4)
			else:
				print('WHY')
				spawn_fire(3)
		
		global_position = global_position.move_toward(pos, delta * SPEED)

func spawn_fire(amount:int):
	var offset = global.rng.randi_range(0,90)
	for i in range(amount):
		var fire = fireScene.instantiate()
		var daAngle = (360 / amount * i) + offset
		fire.initialize(target, 175, daAngle, -3)
		mainScene.call_deferred("add_child", fire)
