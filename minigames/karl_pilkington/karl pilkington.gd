extends Node2D

@onready var parent = global.sceneManager.get_node("Pilkington")

@onready var healthbar = $UI.healthBar
@onready var ui = $UI
@onready var bossbar = $UI/BossBar
@onready var bossAnim = $UI/BossPlayer
@onready var crosshair = $Crosshair
@onready var pilkington
@onready var music = $AudioStreamPlayer
@onready var effectsPlayer = $EffectsPlayer

var pilkScene = preload("res://minigames/karl_pilkington/assets/karl/pilkingtons/standard/pilkington.tscn")

var boosted = false

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	
	spawn_pilkington()
	if parent.pilkPath != null:
		pilkington.add_item(parent.pilkPath)
	
	music.play()

func _unhandled_input(_event):
	#if event.is_action_pressed("ui_accept"):
	#$UpgradeHandler.spawn_upgrade()
	pass

func changeMusic(daMusic):
	music.stream = daMusic
	music.play()

func spawn_pilkington():
	var daPilk = pilkScene.instantiate()
	daPilk.global_position = Vector2(1280/2, 720/2)
	pilkington = daPilk
	pilkington.hurt.connect(healthbar.update_health.bind(pilkington))
	global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", daPilk)
	pilkington.initialize()



