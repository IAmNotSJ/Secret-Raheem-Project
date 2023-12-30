extends Sprite2D

@onready var pillScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/alloy/pill.tscn")

@onready var mainScene = get_tree().root.get_node("KarlPilkington")

var SPEED = 600
var ANGLE_DEGREES = 130

var angle
var isChild = false

var timer:float

var rng = RandomNumberGenerator.new()

func initialize(daAngle, child:bool = false):
	$AnimationPlayer.play(str(rng.randi_range(1,4)))
	angle = daAngle
	isChild = child
	
	timer = rng.randf_range(1, 1.3)
	print(timer)
func _physics_process(delta):
	position.x += SPEED * cos(angle) * delta
	position.y += SPEED * sin(angle) * delta
	rotation_degrees += ANGLE_DEGREES * delta
	
	timer -= delta
	if timer <= 0:
		split()
		queue_free()

func split():
	if !isChild:
		for i in range(-1, 2):
			var coolAngle = mainScene.pilkington.global_position - global_position
			spawn_pill(coolAngle.angle() + (i * 120))

func spawn_pill(leAngle):
	var pill = pillScene.instantiate()
	pill.initialize(leAngle, true)
	pill.global_position = global_position
	get_tree().root.get_node("KarlPilkington").call_deferred("add_child", pill)

func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
