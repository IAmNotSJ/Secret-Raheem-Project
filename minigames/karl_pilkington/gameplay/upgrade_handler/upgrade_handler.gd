extends Node

var upgrade_available:bool = true

@onready var parent = get_parent()
@onready var boss_handler = get_parent().get_node("BossHandler")

const upgradeScene = preload("res://minigames/karl_pilkington/assets/upgrades/upgrade.tscn")

func _ready():
	boss_handler.phase_changed.connect(phase_changed)
	
	$Timer.wait_time = global.rng.randi_range(20, 35)
	$Timer.start()

func spawn_upgrade():
	var upgrade = upgradeScene.instantiate()
	parent.add_child(upgrade)


func _on_timer_timeout():
	print("timeout!")
	spawn_upgrade()
	upgrade_available = false
	if upgrade_available:
		reset_timer()

func reset_timer():
	$Timer.wait_time = global.rng.randi_range(20, 35)
	$Timer.start()

func phase_changed():
	upgrade_available = true
	reset_timer()
