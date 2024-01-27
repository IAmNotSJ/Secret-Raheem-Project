extends Sprite2D

var pilkington

var active:bool = true

func hit():
	if pilkington.cooldown_timer <= 0:
		$AnimationPlayer.play("recharge")
		pilkington.cooldown_timer = pilkington.max_cooldown
