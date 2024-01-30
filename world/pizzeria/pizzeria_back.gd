extends OverworldBase

func _ready():
	if global.items["Pizza"]:
		$Pizza.queue_free()
	DiscordSDKLoader.run_preset("Pizzeria")
	super()

func _on_dialogue_interacted():
	$Pizza.queue_free() 
