extends Control

@onready var bossbar = $BossBar
@onready var healthBar = $HealthBar

func _ready():
	bossbar.visible = false

