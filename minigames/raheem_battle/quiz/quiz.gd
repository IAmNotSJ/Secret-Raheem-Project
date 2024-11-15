extends ScrollContainer


func _on_submit_pressed() -> void:
	get_parent().get_parent()._switch_screen(get_parent().get_parent().INITIAL)
