extends ColorRect

var error_code:String = "" :
	set(value) :
		error_code = value
		%error.text = "Error Code " + error_code

func _on_appdata_pressed() -> void:
	print('gurp?')
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _on_close_pressed() -> void:
	queue_free()
