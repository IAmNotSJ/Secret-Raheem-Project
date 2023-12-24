extends LegacyMember

@onready var pupil = $Pupil
@onready var marker = $Marker2D

@onready var fireScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/flame/fire.tscn")

var pos = Vector2(1280 / 2, 621)

func _process(delta):
	if active:
		look_at_target(target, pupil, marker)
		
		attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			spawn_fire(3)
		
		global_position = global_position.move_toward(pos, delta * SPEED)

func spawn_fire(amount:int):
	var offset = rng.randi_range(0,90)
	for i in range(amount):
		var fire = fireScene.instantiate()
		fire.global_position = pupil.global_position
		var daAngle = (360 / amount * i) + offset
		fire.initialize(target, 175, daAngle, -3)
		get_tree().root.get_node("KarlPilkington").call_deferred("add_child", fire)

func _on_area_2d_area_entered(_area):
	if active:
		hurt()
		$AnimationPlayer.play('hurt')
