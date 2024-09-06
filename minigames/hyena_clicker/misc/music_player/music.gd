extends AudioStreamPlayer

@onready var hyena_clicker = get_parent()

var trackList = [
	{"Path" : "res://minigames/hyena_clicker/music/Lets Get Together Now!.ogg",
	"Title" : "Let's Get Together Now!",
	"Artist" : "SLIME GIRLS",
	"Link" : "https://www.youtube.com/watch?v=GoWgI1V_WDA"},
	{"Path" : "res://minigames/hyena_clicker/music/Bargain Bin Boys.ogg",
	"Title" : "Bargain Bin Boys",
	"Artist" : "SLIME GIRLS",
	"Link" : "ttps://www.youtube.com/watch?v=GoWgI1V_WDA"},
	{"Path" : "res://minigames/hyena_clicker/music/Alphys.ogg",
	"Title" : "Alphys",
	"Artist" : "Toby Fox",
	"Link" : "https://tobyfox.bandcamp.com/track/alphys"},
	{"Path" : "res://minigames/hyena_clicker/music/Everything Will Be Okay.ogg",
	"Title" : "Everything Will Be Okay",
	"Artist" : "Garoad",
	"Link" : "https://garoad.bandcamp.com/track/everything-will-be-okay"},
	{"Path" : "res://minigames/hyena_clicker/music/Breezy Palace.ogg",
	"Title" : "Breezy Palace",
	"Artist" : "Camellia, Toby Fox",
	"Link" : "https://dwellersemptypath.bandcamp.com/track/breezy-palace"},
	{"Path" : "res://minigames/hyena_clicker/music/Cool Cat.ogg",
	"Title" : "Cool Cat",
	"Artist" : "Camellia, Temmie Change, Toby Fox",
	"Link" : "https://dwellersemptypath.bandcamp.com/track/cool-cat"},
	{"Path" : "res://minigames/hyena_clicker/music/The Forest Town.ogg",
	"Title" : "The Forest Town",
	"Artist" : "Calum Bowen",
	"Link" : "https://www.youtube.com/watch?v=aFNgCkFOcXo"},
	{"Path" : "res://minigames/hyena_clicker/music/Checking In.ogg",
	"Title" : "Checking In",
	"Artist" : "Lena Raine",
	"Link" : "https://www.youtube.com/watch?v=fOzvP1I5tLU&list=PLe1jcCJWvkWiWLp9h3ge0e5v7n6kxEfOG&index=6"},
	{"Path" : "res://minigames/hyena_clicker/music/Home Sweet Home.ogg",
	"Title" : "Home Sweet Home",
	"Artist" : "Keiichi Suzuki, Hirokazu Tanaka, Hiroshi Kanazu, Toshiyuki Ueno",
	"Link" : "https://www.youtube.com/watch?v=l8HLmavya0M&list=PL1kU0pk5M3GCwzveqamX71sW3RmCzuXB5&index=17"},
	{"Path" : "res://minigames/hyena_clicker/music/My Dearest Friends.ogg",
	"Title" : "My Dearest Friends",
	"Artist" : "Lena Raine",
	"Link" : "https://www.youtube.com/watch?v=VHN63n9y1vg&list=PLe1jcCJWvkWiWLp9h3ge0e5v7n6kxEfOG&index=21"},
	{"Path" : "res://minigames/hyena_clicker/music/Threed, Free at Last.ogg",
	"Title" : "Threed, Free at Last",
	"Artist" : "Keiichi Suzuki, Hirokazu Tanaka, Hiroshi Kanazu, Toshiyuki Ueno",
	"Link" : "https://www.youtube.com/watch?v=GcERPRac04k&list=PL1kU0pk5M3GCwzveqamX71sW3RmCzuXB5&index=63"},
	{"Path" : "res://minigames/hyena_clicker/music/Knoddys Resort.ogg",
	"Title" : "Knoddys Resort",
	"Artist" : "zKevin",
	"Link" : "https://soundcloud.com/kevinisnotseven/knoddys-resort-1?in=kevinisnotseven/sets/robot64"},
	{"Path" : "res://minigames/hyena_clicker/music/Lost Girl.ogg",
	"Title" : "Lost Girl",
	"Artist" : "Toby Fox",
	"Link" : "https://tobyfox.bandcamp.com/track/lost-girl"},
	{"Path" : "res://minigames/hyena_clicker/music/Lost Library.ogg",
	"Title" : "Lost Library",
	"Artist" : "SLIME GIRLS",
	"Link" : "https://www.youtube.com/watch?v=31jhk_A3mYk"},
	{"Path" : "res://minigames/hyena_clicker/music/It's Raining Somewhere Else.ogg",
	"Title" : "It's Raining Somewhere Else",
	"Artist" : "Toby Fox",
	"Link" : "https://tobyfox.bandcamp.com/track/its-raining-somewhere-else"},
	{"Path" : "res://minigames/hyena_clicker/music/Sweet Sour.ogg",
	"Title" : "Sweet Sour",
	"Artist" : "MasterSwordRemix",
	"Link" : "https://masterswordremix.bandcamp.com/track/sweet-sour"},
]
var curTrack = 0

func _ready():
	await get_tree().process_frame
	if Saves.hyena_stats["First Time"]:
		play_specific_song(0)
		Saves.hyena_stats["First Time"] = false
		Saves.save(Saves.SaveTypes.HYENA)
	else:
		trackList.shuffle()
		play_specific_song(0)

func play_random_song():
	var trackListCopy = trackList
	trackListCopy.shuffle()
	stream = load(trackListCopy[0]["Path"])
	
	var tween = create_tween()
	volume_db = -80
	tween.tween_property(self, "volume_db", 0, 1)
	
	update_song_text(trackListCopy[0]["Title"], trackListCopy[0]["Artist"], trackListCopy[0]["Link"])
	play()

func play_specific_song(song:int = 0):
	stream = load(trackList[song]["Path"])
	volume_db = -80
	var tween = create_tween()
	tween.tween_property(self, "volume_db", 0, 1)
	update_song_text(trackList[song]["Title"], trackList[song]["Artist"], trackList[song]["Link"])
	curTrack += 1
	
	play()

func update_song_text(title:String, artist:String, link:String):
	var textToRepeat:String
	textToRepeat = "       " + '"' + title + '"' + " : " + artist + "       "
	var repeatTimes = floor(1280 / textToRepeat.length())
	hyena_clicker.musicButton.text = ''
	for i in range(repeatTimes):
		hyena_clicker.musicButton.text += textToRepeat
	hyena_clicker.musicButton.position.x = -hyena_clicker.musicButton.size.x
	hyena_clicker.musicButton.modulate.a = 0
	hyena_clicker.musicButton.uri = link


func _on_finished():
	if curTrack >= trackList.size():
		trackList.shuffle()
		curTrack = 0
	play_specific_song(curTrack)
