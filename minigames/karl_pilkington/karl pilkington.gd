extends Node2D

@onready var healthbar = $UI/HealthBar
@onready var bossbar = $UI/BossBar
@onready var bossSprite = $UI/BossSprite
@onready var bossAnim = $UI/BossPlayer
@onready var pilkington
@onready var music = $AudioStreamPlayer

@onready var pilkScene = preload("res://minigames/karl_pilkington/assets/karl/pilkingtons/standard/pilkington.tscn")

@onready var cleftScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/dumb frog.tscn")
@onready var chefScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/the chef.tscn")
@onready var legacyScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/legacies.tscn")
@onready var dapperScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/grabber.tscn")
@onready var monikaScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/monika.tscn")

@onready var enemyArray = [
#legacyScene, 
#chefScene, 
#cleftScene,
#dapperScene,
monikaScene
]

var enemyHealth = 100

const max_enemy_spawn = 7
var enemy_spawn_timer = max_enemy_spawn

var rng = RandomNumberGenerator.new()
var curEnemy

var boosted = false

func _ready():
	spawn_pilkington()
	#spawn_minion("res://minigames/karl_pilkington/assets/karl/minions/harry/harry.tscn")
	bossbar.visible = false
	bossSprite.visible = false
	update_health()
	music.play()
	spawn_enemy()
	
	while is_instance_valid(curEnemy):
		await curEnemy.died
		$EffectsPlayer.play('flash')
		bossbar.visible = false
		bossSprite.visible = false
		music.stop()


func _process(delta):
	if curEnemy == null:
		enemy_spawn_timer -= delta
		if enemy_spawn_timer <= 0:
			spawn_enemy()
	if curEnemy != null:
		bossbar.value = curEnemy.health * 100
func spawn_enemy(path = -1, erase:bool = true):
	if path == -1:
		var arrayCopy = enemyArray
		arrayCopy.shuffle()
		path = arrayCopy[0]
		enemyArray.erase(arrayCopy[0])
	var enemy = path.instantiate()
	enemy.target = pilkington
	get_tree().root.get_node("KarlPilkington").call_deferred("add_child", enemy)
	curEnemy = enemy
	bossbar.visible = true
	bossSprite.visible = true
	update_max_health(enemy.health) 
	bossAnim.play(enemy.name)
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
	get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", daPilk)
	pilkington.initialize()

func spawn_minion(minionPath):
	var minion = load(minionPath).instantiate()
	minion.global_position = pilkington.global_position
	minion.pilkington = pilkington
	get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", minion)

