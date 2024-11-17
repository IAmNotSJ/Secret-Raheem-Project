extends Node2D

@onready var ui = get_parent().get_parent()
@onready var screen_container = get_parent()

const card_position = Vector2(855, 125)
const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

var started:bool = false
var money:int = 0

var win:bool

func create(won:bool):
	win = won
	if ui.game.manager.peer_id == 1 and ui.game.get_player().player_name != ui.game.get_opponent().player_name:
		post_webhook()
	ui.game.manager.clear_peer_ids()
	ui.game.manager.clear_peer_ids.rpc()
	ui.card_hand.block_input()
	screen_container.add_screen_queue(screen_container.RESULTS, false, true)
	
	var card = card_scene.instantiate()
	if ui.game.strongest_card_self:
		card.stats = ui.game.strongest_card_self
		card.is_preview = true
		card.set_card_scale(Vector2(0.75, 0.75))
		card.position.x = ($Strongest.size.x / 2) - card.size.x
		card.position.y = $Strongest.size.y + 20
		card.visible = false
		$Strongest.add_child(card)
	
	Saves.battle_stats["Games Played"] += 1
	if won:
		Saves.battle_stats["Wins"] += 1
	else:
		Saves.battle_stats["Losses"] += 1
	Saves.save(Saves.SaveTypes.BATTLE)
	
	$music.play()
	
	money = money_calculation(ui.game.turn_count, won)
	started = true
	#visible = true
	if won:
		$Result.text = "Congratulations!"
	else:
		$Result.text = "oooh you suck"
	$Money.text = "Coppper Coins Earned: " + str(money)
	$Turns.text = "Turns: " + str(ui.game.turn_count)
	$Cards.text = "Cards Played: " + str(ui.cards_played.size())
	
	await get_tree().create_timer(1).timeout
	$Result.visible = true
	await get_tree().create_timer(1.3).timeout
	$Turns.visible = true
	await get_tree().create_timer(0.3).timeout
	$Cards.visible = true
	await get_tree().create_timer(0.3).timeout
	$Money.visible = true
	if ui.game.strongest_card_self:
		await get_tree().create_timer(0.5).timeout
		card.visible = true
	await get_tree().create_timer(1).timeout
	$Continue.visible = true

func post_webhook():
	var webhook := DiscordWebHook.new(global.WEBHOOK_URL)
	var embed = webhook.add_embed()
	embed.set_title("**MATCH SET**") 
	var description:String = ""
	description += "# " + ui.game.get_player().player_name + " vs. " + ui.game.get_opponent().player_name
	description += "\n\n**__WINNER: __**"
	if win:
		description += "__" + ui.game.get_player().player_name + "__"
	else:
		description += "__" + ui.game.get_opponent().player_name + "__"
	description += "\n**Deck Size:** " + str(ui.game.match_rules["Deck Size"].replace(" Cards", ""))
	description += "\n**Cards To Win:** " + str(ui.game.match_rules["Cards To Win"])
	
	embed.set_description(description)
	embed.set_color(Color8(66, 236, 255))
	#embed.image("https://media.discordapp.net/attachments/1119033198551236783/1297062342948950026/image.jpg?ex=67148ef0&is=67133d70&hm=18aef4348cc63238c90d64ac185e2c9062e0702249667ee168b1ae49451719c7&=&format=webp&width=889&height=889")
	embed.thumbnail("https://media.discordapp.net/attachments/1119033198551236783/1305323371625709699/battle.png?ex=67329c9f&is=67314b1f&hm=5dcb0bbf2db6a9b074d223df6603201fac15fdd7326f783ef6e6c5cd433f0573&=&format=webp&quality=lossless&width=409&height=409")
	
	embed.add_field("Host", ui.game.get_player().player_name)
	embed.add_field("Client", ui.game.get_opponent().player_name)
	embed.add_field("\u200B", "\u200B")
	embed.add_field("Messages Sent", str(ui.chat_box.chat_log.size()), true)
	embed.add_field("Turns", str(ui.game.turn_count), true)
	
	#webhook.post()

func _input(event: InputEvent) -> void:
	if started:
		if event is InputEventKey:
			if event.pressed:
				if ui.game.manager.peer_id != -1:
					print('disconnecting!')
					ui.game.manager.close_peer()
				Transition.change_scene_to_preset("Battle", true, money)
func money_calculation(turn_count:int, won:bool) -> int:
	
	#Minimum amount per game
	var amount:int = 10
	
	# See how many different series you have
	var series_array = []
	var ability_array = []
	for card in Saves.battle_deck[ui.game.match_rules["Deck Size"]]:
		var resource_file = load("res://minigames/raheem_battle/cards/card_variants/stats/" + card + ".tres")
		if !series_array.has(resource_file.card_series):
			series_array.append(resource_file.card_series)
		if !ability_array.has(resource_file.ability_name):
			ability_array.append(resource_file.ability_name)
	
	if turn_count > 8:
		amount += randi_range(2, 5) * (turn_count - 8)
	
	
	for i in range(series_array.size()):
		amount += i * randi_range(1, 3)
	for i in range(ability_array.size()):
		amount += i * randi_range(1, 3)
	
	if won:
		amount += randi_range(10, 20)
	
	# DEMO TAX
	amount /= 6
	
	if ui.kromer:
		amount *= 2
	return amount


func _on_music_finished() -> void:
	$music.play()
