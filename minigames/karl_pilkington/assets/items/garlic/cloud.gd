extends Sprite2D

const max_attack_timer = 0.2
var attack_timer:float = max_attack_timer
const damage = 0.1

const max_disappear_timer = 5
var disappear_timer = max_disappear_timer

func _process(delta):
	disappear_timer -= delta
	if disappear_timer <= 0:
		modulate.a -= delta
		if modulate.a <= 0:
			queue_free()
	if $Hurtbox.get_overlapping_areas() != []:
		attack_timer -= delta
		if attack_timer <= 0:
			attack_timer = max_attack_timer
			for area in $Hurtbox.get_overlapping_areas():
				area.owner.hurt(damage)
