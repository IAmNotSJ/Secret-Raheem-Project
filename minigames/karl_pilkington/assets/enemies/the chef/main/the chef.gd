extends EnemyBase

@onready var kraftScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/kraft/kraft.tscn")
@onready var jrScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/jr/jr.tscn")
@onready var marioScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/mario/mario.tscn")
@onready var pizzaScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/galactose/pizza.tscn")

@onready var attackPlayer = $AttackPlayer

const max_teleport_timer = 3
const max_attack_timer = 5
const max_pizza_timer = 24

var pizza_timer = 6

var teleport_timer = 0.1

var hitcount:int = 0
var hitCounts = [
50,
49,
48,
47,
46,
45,
44,
43,
42,
41,
40,
39,
38,
37,
36,
35,
34,
33,
32,
31,
30,
29,
28,
27,
26,
25,
24,
23,
22,
21,
20,
19,
18,
17,
16,
15,
14,
13,
12,
11,
10,
9,
8,
7,
6,
5,
4,
3,
2,
1,
0
]

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
		
		pizza_timer -= delta
		if pizza_timer <= 0:
			pizza_timer = max_pizza_timer
			spawn_pizza()

func teleport():
	attackPlayer.play('teleport')
	position = Vector2(rng.randi_range(100, 1100), rng.randi_range(50, 600))
	teleport_timer = max_teleport_timer

func hurt(damage):
	$AnimationPlayer.play('hit')
	teleport_timer = .25
	super(damage)
	if health <= hitCounts[hitcount]:
		spawn_kraft(5)
		teleport_timer = 0
		hitcount += 1

func spawn_kraft(division:int = 5):
	var offset = rng.randf_range(0,90)
	for i in range(division):
		var kraft = kraftScene.instantiate()
		kraft.angle = (360 / division * i) + offset
		kraft.global_position = $Marker2D.global_position
		mainScene.call_deferred("add_child", kraft)

func spawn_jr():
	var jr = jrScene.instantiate()
	killOnDeath.append(jr)
	mainScene.call_deferred("add_child", jr)
func spawn_mario():
	var mario = marioScene.instantiate()
	killOnDeath.append(mario)
	mainScene.call_deferred("add_child", mario)

func spawn_pizza():
	var pizza = pizzaScene.instantiate()
	pizza.target = target
	killOnDeath.append(pizza)
	pizza.global_position = $Marker2D.global_position
	mainScene.call_deferred("add_child", pizza)
