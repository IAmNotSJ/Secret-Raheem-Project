extends Sprite2D

@onready var mainScene = global.sceneManager.get_node("Pilkington").get_node("KarlPilkington")
var SPEED = 300
const SHOOT_TIME = 0.5

enum {
	GAIN,
	SHOOT
}

var state = GAIN

var target


func _ready():
	modulate.a = 0
func _process(delta):
	match state:
		GAIN:
			if mainScene.boosted:
				position = position.move_toward(target.position, SPEED * 1.2 * delta)
			else:
				position = position.move_toward(target.position, SPEED * delta)
			modulate.a += delta / 5
			
			if modulate.a >= 1:
				state = SHOOT
				print('shoot state')
				$LightningPlayer.play('strike')
		SHOOT:
			if $Area2D.get_overlapping_areas() != []:
				target.hit()
			if !$LightningPlayer.is_playing():
				queue_free()
