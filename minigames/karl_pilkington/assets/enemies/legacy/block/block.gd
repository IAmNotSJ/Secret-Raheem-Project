extends LegacyMember

@onready var white = $White
@onready var pupil = $Pupil
@onready var marker = $Marker2D

@onready var hitbox = $Area2D
@onready var hitboxShape = $Area2D/CollisionShape2D

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

func replicate_bullet(daPos:Vector2):
	var bullet = bullet_scene.instantiate()
	var dir = target.global_position - daPos
	bullet.start(daPos, dir.angle())
	get_tree().root.get_node("KarlPilkington").call_deferred("add_child", bullet)

func shoot():
	var bullet = basic_bullet.instantiate()
	bullet.global_position = pupil.global_position
	var angleTo = angleToTarget(target, marker)
	bullet.initialize(angleTo, bullet_texture, 700)
	get_tree().root.get_node("KarlPilkington").call_deferred("add_child", bullet)

func _on_area_2d_area_entered(area):
	if active:
		var random = rng.randi_range(0,1)
		match random:
			0:
				$AnimationPlayer.play('block')
				replicate_bullet(area.owner.global_position)
			1:
				$AnimationPlayer.play('hit')
				hurt()
				print(health)
