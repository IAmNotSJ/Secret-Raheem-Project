extends EnemyAttack

func _on_hurtbox_area_entered(area):
	if "walk_speed" in area.owner.get_parent():
		area.owner.get_parent().walk_speed = 100

func _on_hurtbox_area_exited(area):
	if "walk_speed" in area.owner.get_parent():
		area.owner.get_parent().walk_speed = 350
