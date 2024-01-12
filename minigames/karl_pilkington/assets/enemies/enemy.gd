class_name EnemyBase extends CharacterBody2D

var rng = RandomNumberGenerator.new()

@export var health:float = 10
@export var song:AudioStream

@export var hitbox:Area2D

signal died

var target

var killOnDeath = []

func _ready():
	if hitbox != null:
		hitbox.area_entered.connect(_on_area_2d_area_entered)

func hurt(damage:float):
	health -= damage
	if health <= 0:
		die()
	print(health)

func die():
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

func delete():
	died.emit()
	if killOnDeath != []:
		for i in range(killOnDeath.size()):
			killOnDeath[i].queue_free()
	queue_free()

func _on_area_2d_area_entered(area):
	hurt(area.owner.damage)
