## This is a GDscript Node wich gets automatically added as Autoload while installing the addon.
## 
## It can run in the background to comunicate with Discord.
## You don't need to use it. If you remove it make sure to run [code]DiscordSDK.run_callbacks()[/code] in a [code]_process[/code] function.
##
## @tutorial: https://github.com/vaporvee/discord-sdk-godot/wiki
extends Node

func _ready() -> void:
	DiscordSDK.app_id = 1187909876467367946
	run_preset("Menu")

func run_preset(preset:String):
	DiscordSDK.state = "      "
	match preset:
		"Menu":
			DiscordSDK.details = "IN THE MENU"
			DiscordSDK.large_image = "main" # Image key from "Art Assets"
			DiscordSDK.large_image_text = "Happy Anniversary!"
		"Overworld":
			DiscordSDK.details = "OVER THE OVERWORLD"
			DiscordSDK.large_image = "main" # Image key from "Art Assets"
			DiscordSDK.large_image_text = "What's with these howls?"
		"Pizzeria":
			DiscordSDK.details = "BEHIND THE PIZZERIA"
			DiscordSDK.large_image = "main" # Image key from "Art Assets"
			DiscordSDK.large_image_text = "It stinks in here"
		"Cleft":
			DiscordSDK.details = "UNDERNEATH THE HOUSE"
			DiscordSDK.large_image = "main" # Image key from "Art Assets"
			DiscordSDK.large_image_text = "Smells like diet coke"
		"Apartment":
			DiscordSDK.details = "EXPLORING THE APARTMENT"
			DiscordSDK.large_image = "main" # Image key from "Art Assets"
			DiscordSDK.large_image_text = "Just like the episode showed!"
		"Karl":
			DiscordSDK.details = "PLAYING AN ARCADE MACHINE"
			DiscordSDK.large_image = "pilkington" # Image key from "Art Assets"
			DiscordSDK.large_image_text = "This isn't scratch"
		"Hyena":
			DiscordSDK.details = "ROUNDING UP THE CREATURES"
			DiscordSDK.large_image = "hyena" # Image key from "Art Assets"
			DiscordSDK.large_image_text = "THE FOLDER CALLS"
	DiscordSDK.refresh()

func  _process(_delta) -> void:
	DiscordSDK.run_callbacks()
