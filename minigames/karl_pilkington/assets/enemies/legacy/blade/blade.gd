extends LegacyMember

@onready var sliceScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/blade/slice.tscn")

@onready var pupil = $Pupil
@onready var marker = $Marker2D

var pos = Vector2(1189,345)

func _process(delta):
	if active:
		if mainScene.boosted:
			$EffectsPlayer.speed_scale = 1.5
		else:
			$EffectsPlayer.speed_scale = 1.5
		look_at_target(target, pupil, marker)
		position = position.move_toward(pos, delta * SPEED)
		
		attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			slice()

func slice():
	print('le slice!')
	var leSlice = sliceScene.instantiate()
	leSlice.global_position.x = target.global_position.x
	get_tree().root.get_node("KarlPilkington").call_deferred("add_child", leSlice)


func _on_hitbox_entered(area):
	$EffectsPlayer.play('hit')
	super(area)
