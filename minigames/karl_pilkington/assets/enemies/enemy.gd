class_name EnemyBase extends CharacterBody2D

@onready var mainScene = global.sceneManager.get_node("Pilkington").get_node("KarlPilkington")

var rng = RandomNumberGenerator.new()

@export var health:float = 10
@export var song:AudioStream

@export var hitbox:Array[Area2D]

signal died

var target

var killOnDeath = []

func _ready():
	if hitbox != null:
		for i in hitbox.size():
			hitbox[i].area_entered.connect(_on_area_2d_area_entered)

func spawn_entity(entity, global_pos, kod:bool = false):
	if "target" in entity:
		entity.target = target
	if kod:
		killOnDeath.append(entity)
	entity.global_position = global_pos
	mainScene.call_deferred("add_child", entity)

func spawn_bullet(entity, global_pos, degrees):
	if "target" in entity:
		entity.target = target
	entity.global_position = global_pos
	entity.angle = degrees
	mainScene.call_deferred("add_child", entity)

func hurt(damage:float):
	health -= damage
	if health <= 0:
		die()
	print("hurt for " + str(damage))

func die():
	for i in hitbox.size():
		hitbox[i].set_deferred("monitoring", false)
		hitbox[i].set_deferred("monitorable", false)

func delete():
	died.emit()
	print(killOnDeath)
	if killOnDeath != []:
		for i in range(killOnDeath.size()):
			killOnDeath[i].queue_free()
	queue_free()

func _on_area_2d_area_entered(area):
	hurt(area.owner.damage)
