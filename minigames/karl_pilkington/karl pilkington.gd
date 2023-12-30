extends Node2D

@onready var healthbar = $UI/HealthBar
@onready var pilkington = $Pilkington
@onready var music = $AudioStreamPlayer

@onready var cleftScene = preload("res://minigames/karl_pilkington/assets/enemies/dumb frog/dumb frog.tscn")
@onready var chefScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/the chef.tscn")
@onready var legacyScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/legacies.tscn")

@onready var enemyArray = [legacyScene]

const max_enemy_spawn = 7
var enemy_spawn_timer = max_enemy_spawn

var rng = RandomNumberGenerator.new()
var curEnemy

var boosted = false

func _ready():
	update_health()
	music.play()
	spawn_enemy()
	
	while is_instance_valid(curEnemy):
		await curEnemy.died
		$EffectsPlayer.play('flash')
		music.stop()


func _process(delta):
	if curEnemy == null:
		enemy_spawn_timer -= delta
		if enemy_spawn_timer <= 0:
			spawn_enemy()
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
	changeMusic(enemy.song)

func update_health():
	healthbar.play("health " + str(pilkington.health))

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
