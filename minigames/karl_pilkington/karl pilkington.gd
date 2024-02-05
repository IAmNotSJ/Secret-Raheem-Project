extends Node2D

@onready var parent  = get_tree().root.get_node("Pilkington")

@onready var healthbar = $UI/HealthBar
@onready var bossbar = $UI/BossBar
@onready var bossSprite = $UI/BossSprite
@onready var bossAnim = $UI/BossPlayer
@onready var pilkington
@onready var music = $AudioStreamPlayer

@onready var cleftScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/main/dumb frog.tscn")
@onready var chefScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/main/the chef.tscn")
@onready var legacyScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/legacies.tscn")
@onready var dapperScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/main/grabber.tscn")
@onready var monikaScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/main/monika.tscn")

@onready var enemyArray = [
cleftScene,
dapperScene,
chefScene,
legacyScene,
monikaScene
]

@onready var phase1Array = [
cleftScene,
dapperScene
]
@onready var phase2Array = [
chefScene,
#monikaScene
]
@onready var phase3Array = [
legacyScene
]

@onready var phases = [
	phase1Array,
	phase2Array,
	phase3Array
]
var phase = 0

@onready var pilkScene = preload("res://minigames/karl_pilkington/assets/karl/pilkingtons/standard/pilkington.tscn")

var enemyHealth = 100

const max_enemy_spawn = 7
var enemy_spawn_timer = 3

var rng = RandomNumberGenerator.new()
var curEnemy

var boosted = false

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	spawn_pilkington()
	if parent.pilkPath != null:
		pilkington.add_item(parent.pilkPath)
	bossbar.visible = false
	bossSprite.visible = false
	update_health()
	music.play()



func _process(delta):
	if curEnemy == null:
		if phase < 3:
			enemy_spawn_timer -= delta
			if enemy_spawn_timer <= 0:
				spawn_enemy_on_order(phase)
				phase += 1
				enemy_spawn_timer = max_enemy_spawn
		else:
			parent.changeScene("res://minigames/karl_pilkington/win/win_screen.tscn", false)
	else:
		bossbar.value = curEnemy.health * 100
	$Crosshair.global_position = get_global_mouse_position()
	
func spawn_enemy(path = -1, erase:bool = true):
	if path == -1:
		var arrayCopy = enemyArray
		path = arrayCopy[0]
		enemyArray.erase(arrayCopy[0])
	var enemy = path.instantiate()
	enemy.target = pilkington
	get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", enemy)
	curEnemy = enemy
	bossbar.visible = true
	bossSprite.visible = true
	update_max_health(enemy.health) 
	bossAnim.play(enemy.name)
	curEnemy.died.connect(on_enemy_died)
	if enemy.song != null:
		changeMusic(enemy.song)

func spawn_enemy_on_order(daPhase):
	var path = []
	match daPhase:
		0:
			path = phase1Array
		1:
			path = phase2Array
		2: 
			path = phase3Array
	path.shuffle()
	var enemy = path[0].instantiate()
	enemy.target = pilkington
	get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", enemy)
	curEnemy = enemy
	bossbar.visible = true
	bossSprite.visible = true
	update_max_health(enemy.health) 
	bossAnim.play(enemy.name)
	curEnemy.died.connect(on_enemy_died)
	if enemy.song != null:
		changeMusic(enemy.song)

func update_health():
	healthbar.play("health " + str(pilkington.health))

func update_max_health(health):
	bossbar.max_value = health * 100

func _on_pilkington_hurt():
	update_health()

func changeMusic(daMusic):
	music.stream = daMusic
	music.play()

func speedMusic(speed:float):
	var tween = get_tree().create_tween()
	tween.tween_property(music, "pitch_scale", speed, 0.2)

func _on_audio_stream_player_finished():
	music.play()

func spawn_pilkington():
	var daPilk = pilkScene.instantiate()
	daPilk.global_position = Vector2(1280/2, 720/2)
	pilkington = daPilk
	pilkington.hurt.connect(update_health)
	get_tree().get_root().get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", daPilk)
	pilkington.initialize()

func spawn_minion(minionPath):
	var minion = load(minionPath).instantiate()
	minion.global_position = pilkington.global_position
	minion.pilkington = pilkington
	get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", minion)

func on_enemy_died():
	$EffectsPlayer.play('flash')
	bossbar.visible = false
	bossSprite.visible = false
	music.stop()

