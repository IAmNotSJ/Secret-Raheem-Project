extends Node2D

var posThingy = 0

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	global.mouse.make_visible()
	DiscordSDKLoader.run_preset("Menu")
	$fade.visible = true
	%version.text = "Version " + ProjectSettings.get_setting("application/config/version")
func _process(delta):
	posThingy += delta
	if $fade.modulate.a > 0:
		$fade.modulate.a -= delta
	$Parallax.position.y = 662 - 10 * sin(posThingy)
	$Parallax2.position.y = -10 + 10 * sin(posThingy)

func _on_begin_pressed():
	#$no.play()
	if $Password.visible:
		$Password.visible = false
	else:
		$Password.visible = true
	#Transition.change_scene_to_preset("Overworld")

func _on_settings_pressed():
	$Settings.visible = true

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()


func _on_games_pressed():
	$Games.visible = true


func _on_debug_pressed() -> void:
	Transition.change_scene_to_preset("Debug")


func _on_password_line_text_submitted(new_text: String) -> void:
	if new_text == "hellothisismypassword":
		Transition.change_scene_to_preset("Overworld")
	else:
		$Password.visible = false
