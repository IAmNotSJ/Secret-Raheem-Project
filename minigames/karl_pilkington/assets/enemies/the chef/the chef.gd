extends EnemyBase

@onready var kraftScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/kraft.tscn")
@onready var jrScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/jr.tscn")
@onready var marioScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/mario.tscn")

@onready var attackPlayer = $AttackPlayer

const max_teleport_timer = 3
const max_attack_timer = 5

var rng = RandomNumberGenerator.new()

var teleport_timer = 0.1

var phase:int = 1

var dead = false

func _process(delta):
	if !dead:
		teleport_timer -= delta
		if teleport_timer <= 0:
			teleport()
		
		if health <= 35 and phase == 1:
			phase = 2
			spawn_jr()
		if health <= 15 and phase == 2:
			phase = 3
			spawn_mario()
		if health <= 0:
			dead = true
			$AnimationPlayer.play("died")

func teleport():
	attackPlayer.play('teleport')
	position = Vector2(rng.randi_range(100, 1100), rng.randi_range(50, 600))
	teleport_timer = max_teleport_timer

func hurt():
	$AnimationPlayer.play('hit')
	spawn_kraft(5)
	teleport_timer = .25
	super()

func spawn_kraft(division:int = 5):
	var offset = rng.randf_range(0,90)
	for i in range(division):
		var kraft = kraftScene.instantiate()
		kraft.start((360 / division * i) + offset)
		kraft.global_position = $Marker2D.global_position
		get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", kraft)

func spawn_jr():
	var jr = jrScene.instantiate()
	killOnDeath.append(jr)
	get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", jr)
func spawn_mario():
	var mario = marioScene.instantiate()
	killOnDeath.append(mario)
	get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", mario)

func _on_hurtbox_area_entered(_area):
	hurt()
