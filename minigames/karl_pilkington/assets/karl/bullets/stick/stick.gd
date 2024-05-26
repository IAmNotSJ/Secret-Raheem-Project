extends BulletBase


#Exists just to make sure that enemies cannot get hit multiple times over a couple frames
#More practical solution would be to just add i frames but not really worth it considering that this situation
#will only appear like a couple times :P
var hurtEnemies:Array = []

func _process(_delta):
	if $Stick/Hurtbox.monitoring and $Stick/Hurtbox.get_overlapping_areas() != []:
		for area in $Stick/Hurtbox.get_overlapping_areas():
			if hurtEnemies.find(area.owner) == -1:
				area.owner.hurt(damage)
				hurtEnemies.append(area.owner)

func start(_position, _direction, _damage):
	position = _position
	rotation = _direction
	damage *= _damage
	$Stick/AnimationPlayer.play("swing")

func end():
	hurtEnemies = []
	queue_free()
