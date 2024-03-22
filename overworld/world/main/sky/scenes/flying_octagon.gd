extends Sprite2D

enum {
	IDLE,
	FALL
}
var state = IDLE

const max_progress = 70
var progress:float = max_progress
var acceleration:float = 1



func _process(delta):
	match state:
		IDLE:
			if $Visible.is_on_screen():
				progress -= delta
				print(progress)
			else:
				progress = max_progress
			if progress <= 0:
				state = FALL
				$AnimationPlayer.play('boom')
				global.octagon_fallen = true
				$AudioStreamPlayer.play()
		FALL:
			acceleration += delta * 5
			position.y += 15 * delta * acceleration
			if position.y >= -719:
				queue_free()
