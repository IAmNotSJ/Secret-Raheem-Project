extends Node2D

@onready var ui = get_parent().get_parent()
@onready var screen_container = get_parent()

var started:bool = false
var money:int = 0

func create(won:bool):
	ui.game.manager.clear_peer_ids()
	ui.game.manager.clear_peer_ids.rpc()
	ui.card_hand.block_input()
	screen_container.add_screen_queue(screen_container.RESULTS, false, true)
	
	Saves.battle_stats["Games Played"] += 1
	if won:
		Saves.battle_stats["Wins"] += 1
	else:
		Saves.battle_stats["Losses"] += 1
	Saves.save(Saves.SaveTypes.BATTLE)
	
	money = money_calculation(ui.game.turn_count, won)
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
				Transition.change_scene_to_preset("Battle", true, money)
				pass
func money_calculation(turn_count:int, won:bool) -> int:
	
	var amount:int = 60
	# See how many different series you have
	var series_array = []
	for card in Saves.battle_deck.values():
		var resource_file = load("res://minigames/raheem_battle/cards/card_variants/stats/" + card + ".tres")
		if !series_array.has(resource_file.card_series):
			series_array.append(resource_file.card_series)
	
	if turn_count > 8:
		amount += randi_range(20, 30) * (turn_count - 8)
	
	for i in range(series_array.size()):
		amount += i * randi_range(30, 60)
	
	if won:
		amount += randi_range(70, 100)
	return amount
