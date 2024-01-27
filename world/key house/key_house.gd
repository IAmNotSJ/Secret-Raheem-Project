extends OverworldBase

func _ready():
	$AudioStreamPlayer.play()
	super()

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
