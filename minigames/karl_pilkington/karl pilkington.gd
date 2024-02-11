extends Node2D

@onready var parent  = get_tree().root.get_node("Pilkington")

@onready var healthbar = $UI.healthBar
@onready var bossbar = $UI/BossBar
@onready var bossAnim = $UI/BossPlayer
@onready var pilkington
@onready var music = $AudioStreamPlayer

var pilkScene = preload("res://minigames/karl_pilkington/assets/karl/pilkingtons/standard/pilkington.tscn")

const cleftScene = "res://minigames/karl_pilkington/assets/enemies/dumb frog/main/dumb frog.tscn"
const chefScene = "res://minigames/karl_pilkington/assets/enemies/the chef/main/the chef.tscn"
const legacyScene = "res://minigames/karl_pilkington/assets/enemies/legacy/legacies.tscn"
const dapperScene = "res://minigames/karl_pilkington/assets/enemies/grabber/main/grabber.tscn"
const monikaScene = "res://minigames/karl_pilkington/assets/enemies/monika/main/monika.tscn"

var upgradeScene = load("res://minigames/karl_pilkington/assets/upgrades/upgrade.tscn")

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
var phase_count = 3
var phase = 0
var enemies = []

var curEnemy

const max_enemy_spawn = 7
var enemy_spawn_timer = 3

var boosted = false

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	
	if parent.debugOptions["Spawn Enemies"]:
		set_enemy_rotation()
	
	spawn_pilkington()
	if parent.pilkPath != null:
		pilkington.add_item(parent.pilkPath)
	
	music.play()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		spawn_upgrade()

func _process(delta):
	if parent.debugOptions["Spawn Enemies"]:
		if curEnemy == null:
			if phase < phase_count:
				enemy_spawn_timer -= delta
				if enemy_spawn_timer <= 0:
					spawn_enemy_on_order(phase)
					phase += 1
					enemy_spawn_timer = max_enemy_spawn
			else:
				parent.changeScene("res://minigames/karl_pilkington/win/win_screen.tscn", false)
		else: 
			bossbar.value = curEnemy.health * 100
	
	#Note to self: Try and find more accurate way of following 
	$Crosshair.global_position = get_global_mouse_position()

func set_enemy_rotation():
	for i in range(phase_count):
		enemies.append(load(phases[i][global.rng.randi_range(0, phases[i].size() - 1)]))

func spawn_enemy_on_order(daPhase):
	var enemy = enemies[daPhase].instantiate()
	enemy.target = pilkington
	get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", enemy)
	curEnemy = enemy
	bossbar.visible = true
	update_max_health(enemy.health) 
	bossAnim.play(enemy.name)
	curEnemy.died.connect(on_enemy_died)
	if enemy.song != null:
		changeMusic(enemy.song)

func spawn_upgrade():
	var upgrade = upgradeScene.instantiate()
	add_child(upgrade)

func update_health():
	healthbar.lower_health(pilkington.health)
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

func on_enemy_died():
	$EffectsPlayer.play('flash')
	bossbar.visible = false
	music.stop()

