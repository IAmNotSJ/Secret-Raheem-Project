class_name LegacyMember extends CharacterBody2D

signal died

@export var health = 20
@export var SPEED = 100
@export var eyeradius = 4

@export var ATTACK_TIMER = 3

var rng = RandomNumberGenerator.new()

var attackTimer = ATTACK_TIMER

var active

var target

func change_active():
	if active:
		active = false
		position = Vector2(1400, -100)
	if !active:
		active = true

func look_at_target(daTarget, pupil, marker):
	var angleTo = angleToTarget(daTarget, marker)
	pupil.position.x = eyeradius * cos(angleTo) + marker.position.x
	pupil.position.y = eyeradius * sin(angleTo) + marker.position.y

func angleToTarget(daTarget, marker):
	var direction = daTarget.global_position - global_position
	var angleTo = marker.transform.x.angle_to(direction)
	return angleTo

func hurt():
	health -= 1
	
	if health <= 0:
		die()

func die():
	died.emit()
	queue_free()
