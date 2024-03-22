extends AudioStreamPlayer

var playList:Array

func playSong(song:AudioStream):
	if playing:
		stop()
	stream = song
	play()

func setNewPlaylist(_playlist:Array, _play:bool = true):
	pass
