extends Node2D

var pilkington:PilkingtonBase
var shieldRadius = 80

func _physics_process(_delta):
	var dir = (get_global_mouse_position() - global_position).angle() + deg_to_rad(180)
	rotation = dir + deg_to_rad(90)
	position.x = shieldRadius * cos(dir) + pilkington.center.position.x
	position.y = shieldRadius * sin(dir) + pilkington.center.position.y

func hit():
	if pilkington.cooldown_timer <= 0:
		$PictureSprite/AnimationPlayer.play("recharge")
		pilkington.cooldown_timer = pilkington.max_cooldown
