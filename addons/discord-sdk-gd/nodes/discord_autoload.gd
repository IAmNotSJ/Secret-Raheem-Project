## This is a GDscript Node wich gets automatically added as Autoload while installing the addon.
## 
## It can run in the background to comunicate with Discord.
## You don't need to use it. If you remove it make sure to run [code]DiscordSDK.run_callbacks()[/code] in a [code]_process[/code] function.
##
## @tutorial: https://github.com/vaporvee/discord-sdk-godot/wiki
extends Node

var presets:Dictionary = {
	"Menu" : ["IN THE MENUS", "main", "Happy Anniversary!"],
	"Overworld" : ["OVER THE OVERWORLD", "main", "What's with these howls?"],
	"Pizzeria" : ["BEHIND THE PIZZERIA", "main", "It stinks in here"],
	"Cleft" : ["UNDERNEATH THE HOUSE", "main", "Smells like diet coke"],
	"Apartment" : ["EXPLORING THE APARTMENT", "main", "Just like the episode showed!"],
	"Karl" : ["PLAYING AN ARCADE MACHINE", "pilkington", "This isn't scratch"],
	"Hyena" : ["ROUNDING UP THE CREATURES", "hyena", "THE FOLDER CALLS"],
	"Battle" : ["BATTLING CARDS", "battle", "So Cool!"],
	"Art" : ["mind your business maybe", "main", "Mama Mia!"]
}

func _ready() -> void:
	DiscordSDK.app_id = 1187909876467367946
	run_preset("Menu")

func run_preset(preset:String):
	DiscordSDK.details = presets[preset][0]
	DiscordSDK.large_image= presets[preset][1]
	DiscordSDK.large_image_text = presets[preset][2]
	DiscordSDK.state = "      " # Just makes it blank :P
	DiscordSDK.refresh()

func  _process(_delta) -> void:
	DiscordSDK.run_callbacks()
