extends EnemyBullet

func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
