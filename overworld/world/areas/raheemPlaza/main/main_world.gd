extends OverworldBase

var trackList = [
	preload("res://overworld/music/A Bit of Peace and Quiet.ogg"),
	preload("res://overworld/music/Map (Night).ogg"),
	preload("res://overworld/music/Persistent Joy.ogg")
]

func _ready():
	$AudioStreamPlayer.stream = trackList[randi_range(0, trackList.size() - 1)]
	$AudioStreamPlayer.play()
	
	DiscordSDKLoader.run_preset("Overworld")
	super()

func _on_key_interacted():
	if Saves.items["Pizza"] == true and Saves.unlocks["Cleft"] == true:
		$Chars/Key.animationPlayer.play('empty')


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.stream = trackList[randi_range(0, trackList.size() - 1)]
	$AudioStreamPlayer.play()
