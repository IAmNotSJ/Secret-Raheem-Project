extends Node2D

var posThingy = 0

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	DiscordSDKLoader.run_preset("Menu")
	$ColorRect.visible = true
func _process(delta):
	posThingy += delta
	if $ColorRect.modulate.a > 0:
		$ColorRect.modulate.a -= delta
	$Parallax.position.y = 662 - 10 * sin(posThingy)
	$Parallax2.position.y = -10 + 10 * sin(posThingy)

func _on_begin_pressed():
	Transition.change_scene_to_preset("Overworld")

func _on_settings_pressed():
	$Settings.visible = true

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()


func _on_games_pressed():
	$Games.visible = true
