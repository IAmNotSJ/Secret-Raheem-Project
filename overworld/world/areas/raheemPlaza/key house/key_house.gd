extends OverworldBase

func _ready():
	$AudioStreamPlayer.play()
	DiscordSDKLoader.run_preset("Cleft")
	super()

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
