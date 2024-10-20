extends Node2D

@onready var ui = get_parent().get_parent()
@onready var screen_container = get_parent()

var started:bool = false

func create(won:bool):
	ui.game.manager.disconnect_discrete()
	ui.card_hand.block_input()
	screen_container.add_screen_queue(screen_container.RESULTS, false, true)
	
	var money = money_calculation()
	started = true
	#visible = true
	if won:
		$Result.text = "Congratulations!"
	else:
		$Result.text = "oooh you suck"
	$Money.text = "Money Earned: " + str(money)
	
	await get_tree().create_timer(1).timeout
	$Result.visible = true
	await get_tree().create_timer(1.3).timeout
	$Turns.visible = true
	await get_tree().create_timer(0.3).timeout
	$Cards.visible = true
	await get_tree().create_timer(0.3).timeout
	$Money.visible = true
	await get_tree().create_timer(1).timeout
	$Continue.visible = true

func webhook():
	var hook := DiscordWebHook.new(global.WEBHOOK_URL)
	
	var embed = hook.add_embed()
	embed.set_title("MATCH SET") 
	embed.set_description("This is my embeds description")
	embed.set_color(Color.RED)
	
	hook.post()

func _input(event: InputEvent) -> void:
	if started:
		if event is InputEventKey:
			if event.pressed:
				print('gurp')
				ui.game.manager.return_to_menu("")
				pass
func money_calculation():
	return 100
