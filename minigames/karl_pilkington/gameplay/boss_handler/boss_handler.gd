extends Node

signal phase_changed

@onready var parent = get_parent()

const dummyScene = "res://minigames/karl_pilkington/assets/enemies/dummy/main/dummy.tscn"

const cleftScene = "res://minigames/karl_pilkington/assets/enemies/dumb frog/main/dumb frog.tscn"
const chefScene = "res://minigames/karl_pilkington/assets/enemies/the chef/main/the chef.tscn"
const legacyScene = "res://minigames/karl_pilkington/assets/enemies/legacy/legacies.tscn"
const dapperScene = "res://minigames/karl_pilkington/assets/enemies/grabber/main/grabber.tscn"
const monikaScene = "res://minigames/karl_pilkington/assets/enemies/monika/main/monika.tscn"
const carlScene = "res://minigames/karl_pilkington/assets/enemies/carl pilkington/main/carl.tscn"

var fullEnemyList:Array = [
	cleftScene,
	dapperScene,
	chefScene,
	monikaScene,
	legacyScene,
	carlScene
]

var phase1Array = [
cleftScene,
dapperScene
]
var phase2Array = [
chefScene,
monikaScene
]
var phase3Array = [
legacyScene
]
var phases = [
	phase1Array,
	phase2Array,
	phase3Array
]

var customOrder = []


var phase_count = 3
var phase = 0
var enemies = []

var curEnemy

const max_enemy_spawn = 7
var enemy_spawn_timer = 3

func _ready():
	if parent.get_parent().debugOptions["Spawn Enemies"]:
		set_enemy_rotation()
	if parent.get_parent().debugOptions["Spawn Dummy"]:
		call_deferred("spawn_enemy", dummyScene)

func _process(delta):
	if parent.parent.debugOptions["Spawn Enemies"]:
		if curEnemy == null:
			if phase < phase_count:
				enemy_spawn_timer -= delta
				if enemy_spawn_timer <= 0:
					spawn_enemy_on_order(phase)
					phase += 1
					phase_changed.emit()
					enemy_spawn_timer = max_enemy_spawn
			else:
				if parent.cheating:
					print('ADD DEBUG WIN SCREEN')
				else:
					parent.parent.changeScene("res://minigames/karl_pilkington/win/win_screen.tscn", false)
		else: 
			parent.bossbar.value = curEnemy.health * 100

func set_enemy_rotation():
	for i in range(phase_count):
		if customOrder == []:
			enemies.append(load(phases[i][global.rng.randi_range(0, phases[i].size() - 1)]))
		else:
			if customOrder.size() < i:
				enemies.append(load(customOrder[i]))
			else:
				enemies.append(load(fullEnemyList[global.rng.randi_range(0, fullEnemyList.size() - 1)]))

func spawn_enemy_on_order(daPhase):
	var enemy = enemies[daPhase].instantiate()
	enemy.target = parent.pilkington
	global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", enemy)
	curEnemy = enemy
	parent.bossbar.visible = true
	parent.ui.update_max_health(enemy.health) 
	parent.bossAnim.play(enemy.name)
	curEnemy.died.connect(on_enemy_died)
	if enemy.song != null:
		parent.changeMusic(enemy.song)

func on_enemy_died():
	parent.effectsPlayer.play('flash')
	parent.bossbar.visible = false
	parent.music.stop()

func spawn_enemy(path):
	var enemy = load(path).instantiate()
	enemy.target = parent.pilkington
	global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", enemy)
