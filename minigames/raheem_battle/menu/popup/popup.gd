extends Sprite2D



var error_code:String = "" :
	set(value) :
		error_code = value
		_on_error_code_changed(error_code)

func _on_error_code_changed(code):
	%error.text = "Error Code " + error_code
	match code:
		"":
			$Sorry.visible = false
		"003":
			$text.text = "Connection to server failed!"
			$Sorry.visible = false
			$appdata.visible = false
		"004":
			$text.text = "You do not have enough cards to play! Please select 8 cards from your deck in order to continue to a match!"
			$Sorry.visible = false
			$appdata.visible = false
		"005":
			$text.text = "That match is full! Please try again once the match has ended!"
			$Sorry.visible = false
			$appdata.visible = false

func _on_appdata_pressed() -> void:
	print('gurp?')
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _on_close_pressed() -> void:
	queue_free()
