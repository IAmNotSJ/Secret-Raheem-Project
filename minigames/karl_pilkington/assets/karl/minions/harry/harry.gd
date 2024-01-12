extends CharacterBody2D

enum {
	ALIVE,
	DEAD
}
var state = ALIVE

const SPEED = 50

@onready var explosion = $Explosion

var pilkington

var rng = RandomNumberGenerator.new()

var explode_timer = rng.randi_range(7, 35)
var respawn_timer = rng.randi_range(25, 54)
func _ready():
	pass
func _process(delta):
	match state:
		ALIVE:
			print(explode_timer)
			explode_timer -= delta
			if explode_timer <= 0:
				explode_timer = rng.randi_range(7, 75)
				explode()
				state = DEAD
			position = position.move_toward(pilkington.position, SPEED * delta)
		DEAD:
			print(respawn_timer)
			respawn_timer -= delta
			if respawn_timer <= 0:
				respawn_timer = rng.randi_range(25, 54)
				respawn()
				state = ALIVE

func respawn():
	visible = true
	$RespawnPlayer.play('respawn')
func explode():
	explosion.monitoring = true
	$ExplosionPlayer.play('explode')
	
	if explosion.get_overlapping_areas() != []:
		for i in explosion.get_overlapping_areas().size():
			explosion.get_overlapping_areas()[i].hurt(rng.randi_range(15, 40))
	explosion.monitoring = false
	visible = false
