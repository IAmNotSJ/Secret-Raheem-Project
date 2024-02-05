extends LegacyMember

@onready var white = $White
@onready var pupil = $Pupil
@onready var marker = $Marker2D

@onready var bullet_scene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/block/bullet.tscn")

@onready var basic_bullet = preload("res://minigames/karl_pilkington/assets/enemies/legacy/basic_bullet.tscn")
@onready var bullet_texture = preload("res://minigames/karl_pilkington/assets/enemies/legacy/block/bullet.png")

var pos = Vector2(50, 644)

func _process(delta):
	if active:
		look_at_target(target, pupil, marker)
		position = position.move_toward(pos, delta * SPEED)
		attackTimer -= delta
		if attackTimer <= 0:
			shoot()
			attackTimer = ATTACK_TIMER

func replicate_bullet(daPos:Vector2, angleOffset = 0):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = daPos
	var direction = target.global_position - $Marker2D.global_position
	var angleTo = $Marker2D.transform.x.angle_to(direction)
	bullet.angle =  rad_to_deg(angleTo) + angleOffset
	mainScene.call_deferred("add_child", bullet)

func shoot():
	var bullet = basic_bullet.instantiate()
	bullet.global_position = pupil.global_position
	var angleTo = angleToTarget(target, marker)
	bullet.start(rad_to_deg(angleTo), bullet_texture, 700)
	mainScene.call_deferred("add_child", bullet)

func _on_hitbox_entered(area):
	if active:
		var random = global.rng.randi_range(0,1)
		match random:
			0:
				$EffectsPlayer.play('block')
				if mainScene.boosted:
					for i in range(-1, 2):
						replicate_bullet(area.owner.global_position, (7 * i))
				else:
					replicate_bullet(area.owner.global_position)
			1:
				super(area)
