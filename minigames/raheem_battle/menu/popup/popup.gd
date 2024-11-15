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
		"004-8":
			$text.text = "You do not have enough cards to play! Please select 8 cards from your deck in order to continue to a match!"
			$Sorry.visible = false
			$appdata.visible = false
		"004-9":
			$text.text = "You do not have enough cards to play! Please select 9 cards from your deck in order to continue to a match!"
			$Sorry.visible = false
			$appdata.visible = false
		"004-10":
			$text.text = "You do not have enough cards to play! Please select 10 cards from your deck in order to continue to a match!"
			$Sorry.visible = false
			$appdata.visible = false
		"004-11":
			$text.text = "You do not have enough cards to play! Please select 11 cards from your deck in order to continue to a match!"
			$Sorry.visible = false
			$appdata.visible = false
		"004-12":
			$text.text = "You do not have enough cards to play! Please select 12 cards from your deck in order to continue to a match!"
			$Sorry.visible = false
			$appdata.visible = false
		"005":
			$text.text = "That match is full! Please try again once the match has ended!"
			$Sorry.visible = false
			$appdata.visible = false
		"006":
			$text.text = "Joining timed out! Either the game you are trying to join does not exist or there is a clienside issue, in which you should restart your game"
			$Sorry.visible = true
			$appdata.visible = false
		"007":
			$text.text = "Game versions do not match! Please update your game! (Or tell the person you're joining to update)"
			$Sorry.visible = false
			$appdata.visible = false
		"008":
			$text.text = "UPNP Discover Failed! You may not have UPNP enabled on your router! DM SJ to see if this can be fixed"
			$Sorry.visible = true
			$appdata.visible = false
		"009":
			$text.text = "UPNP Setup failed! You might not have UPNP enabled on your router! DM SJ to see if this can be fixed"
			$Sorry.visible = true
			$appdata.visible = false

func _on_appdata_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func _on_close_pressed() -> void:
	queue_free()
