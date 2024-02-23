extends Node2D

@onready var parent = get_tree().root.get_node("Pilkington")

@onready var healthbar = $UI.healthBar
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

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		$UpgradeHandler.spawn_upgrade()


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

