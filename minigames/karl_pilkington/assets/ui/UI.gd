extends Control

@onready var bossbar = $BossBar
@onready var healthBar = $HealthBar

func _ready():
	bossbar.visible = false

func update_max_health(health):
	bossbar.max_value = health * 100
