extends CanvasGroup

func _ready():
	$Bar.play("health 5")

func lower_health(health):
	$Bar.play("health " + str(health))
	if health < 0:
		$iconPlayer.play('worried')
	else:
		$iconPlayer.play('dead')
	$hitPlayer.play('hit')
