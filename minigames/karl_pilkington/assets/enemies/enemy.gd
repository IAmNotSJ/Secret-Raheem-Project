class_name EnemyBase extends CharacterBody2D

@export var health = 10
@export var song:AudioStream

signal died

var target

var killOnDeath = []

func hurt():
	health -= 1
	if health <= 0:
		die()
	print(health)

func die():
	pass

func delete():
	died.emit()
	if killOnDeath != []:
		for i in range(killOnDeath.size()):
			killOnDeath[i].queue_free()
	queue_free()


