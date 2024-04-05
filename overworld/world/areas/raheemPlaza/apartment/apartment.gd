extends OverworldBase

func _ready():
	DiscordSDKLoader.run_preset("Apartment")
	super()
