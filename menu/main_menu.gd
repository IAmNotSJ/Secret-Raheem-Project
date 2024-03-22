extends Node2D

var posThingy = 0

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	DiscordSDKLoader.run_preset("Menu")
	#if !global.minigames["Karl Pilkington"]:
	$Main/Karl.queue_free()
	#if !global.minigames["Hyena Clicker"]:
	$Main/Hyena.queue_free()
	$ColorRect.visible = true
func _process(delta):
	posThingy += delta
	if $ColorRect.modulate.a > 0:
		$ColorRect.modulate.a -= delta
	$Parallax.position.y = 662 - 10 * sin(posThingy)
	$Parallax2.position.y = -10 + 10 * sin(posThingy)

func _on_begin_pressed():
	Transition.change_scene_to_preset("Overworld")


func _on_karl_pressed():
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Pilkington")
func _on_hyena_pressed():
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Hyena")


func _on_settings_pressed():
	$Settings.visible = true


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
