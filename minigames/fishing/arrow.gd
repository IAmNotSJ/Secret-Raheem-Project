extends Sprite2D

func playAnim(anim:String):
	match anim:
		'shake':
			$"shake player".play("shake")
		'scale':
			$"scale player".play("scale")
