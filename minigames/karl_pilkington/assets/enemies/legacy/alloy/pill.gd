extends EnemyBullet

@onready var pillScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/alloy/pill.tscn")

@onready var mainScene = get_tree().root.get_node("Pilkington").get_node("KarlPilkington")

var ANGLE_DEGREES = 130

var isChild = false

var timer:float

func _ready():
	$AnimationPlayer.play(str(global.rng.randi_range(1,4)))
	timer = global.rng.randf_range(1, 1.3)
	super()

func _process(delta):
	rotation_degrees += ANGLE_DEGREES * delta
	super(delta)
	
	timer -= delta
	if timer <= 0:
		split()
		queue_free()

func split():
	if !isChild:
		for i in range(-1, 2):
			var coolAngle = 0
			if mainScene.boosted:
				coolAngle = (mainScene.pilkington.global_position - global_position).angle()
			spawn_pill(coolAngle + (i * 15))

func spawn_pill(leAngle):
	var pill = pillScene.instantiate()
	angle = leAngle
	isChild = true
	pill.global_position = global_position
	mainScene.call_deferred("add_child", pill)
