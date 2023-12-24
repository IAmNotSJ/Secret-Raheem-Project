extends Sprite2D

@onready var bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/the chef/bullet.tscn")

@onready var curAngle = $Gun.rotation_degrees

enum {
	INTRO,
	SHOOT,
	BREAK
}
var state = INTRO

const shoot_time:float = 0.2

var shooting_timer:float = shoot_time

var modifier:int = 1

func _process(delta):
	match state:
		INTRO:
			if !$AnimationPlayer.is_playing():
				state = SHOOT
				$AnimationPlayer.play('shoot')
		SHOOT:
			$Gun.rotation_degrees += 50 * delta * modifier
			if $Gun.rotation_degrees >= 120:
				modifier = -1
			elif $Gun.rotation_degrees <= -60:
				modifier = 1
			shooting_timer -= delta
			if shooting_timer <= 0:
				shooting_timer = shoot_time
				spawn_bullet($Gun.rotation_degrees)

func spawn_bullet(angle):
	var bullet = bulletScene.instantiate()
	bullet.global_position = $Gun/Marker2D.global_position
	bullet.angle = angle
	get_tree().get_root().get_node("KarlPilkington").call_deferred("add_child", bullet)
