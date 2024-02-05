extends LegacyMember

@onready var hurtbox = $Sprite2D/Hitbox
@onready var pupil = $Sprite2D/Pupil
@onready var marker = $Sprite2D/Marker2D

@onready var sandScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/basic_bullet.tscn")
@onready var sand_texture = preload("res://minigames/karl_pilkington/assets/enemies/legacy/sand/bullet.png")

var pos = Vector2(321, 106)

var fakeBoost:bool

func _process(delta):
	if active:
		if mainScene.boosted:
			attackTimer -= delta * 3
		else:
			attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			shoot()
		global_position = global_position.move_toward(pos, delta * SPEED)
		look_at_target(target, pupil, marker)

func shoot():
	for i in range(-1, 2):
		print('shot')
		var sand = sandScene.instantiate()
		sand.global_position = pupil.global_position
		var angleTo = angleToTarget(target, marker)
		sand.start(rad_to_deg(angleTo) + (i * -15), sand_texture, 600)
		mainScene.call_deferred("add_child", sand)
