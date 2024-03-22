class_name LegacyMember extends CharacterBody2D

signal died

@onready var mainScene = global.sceneManager.get_node("Pilkington").get_node("KarlPilkington")
@onready var legacyScene = global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").get_node("Lazy League")

@export var health:float = 20
@export var SPEED = 100
@export var eyeradius = 4

@export var ATTACK_TIMER = 3
var attackTimer = ATTACK_TIMER

@export var hitbox:Area2D
@export var hitPlayer:AnimationPlayer

var rng = RandomNumberGenerator.new()

var boosted:bool = false
var active

var target

func _ready():
	hitbox.area_entered.connect(self._on_hitbox_entered)

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

func hurt(damage:float = 1):
	if damage > health:
		legacyScene.health -= health * 100
	else:
		legacyScene.health -= damage * 100
	health -= damage
	
	if health <= 0:
		die()

func die():
	died.emit()
	queue_free()

func hit_target(area):
	area.get_parent().get_parent().hit()

func change_boost(val:bool):
	boosted = val

func _on_hitbox_entered(area):
	if active:
		hurt(area.owner.damage)
		hitPlayer.play('hit')
