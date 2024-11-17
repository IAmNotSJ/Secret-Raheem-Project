extends Control

signal turn_started
signal turn_ended
signal sync

signal entered_preview
signal exited_preview

signal card_played
signal card_rejected

const LOG_PATH:String = "user://raheem_battle_log.log"

#You get the drill by now
enum Sides {
	ATTACKING,
	DEFENDING,
	TIE
}
enum FutureEvents {
	NEXT_CARD_BONUS,
	NEXT_CARD_PENALTY,
	NEXT_LOSS_BONUS,
	NEXT_LOSS_PENALTY,
	NEXT_CARD_BONUS_MULTIPLIER,
	NEXT_CARD_PENALTY_MULTIPLIER
}

enum Stages {
	NOT_STARTED,
	PRE_TURN,
	TURN,
	POST_TURN
}
var cur_stage:Stages = Stages.NOT_STARTED :
	set(value):
		cur_stage = value
		# Mainly a precaution, hopefully won't break everything?
		card_hand.reindex_deck()

@onready var game = get_parent().get_parent()

@onready var card_hand = $card_hand
@onready var extra_screens = $extra_screens
@onready var card_preview = extra_screens.card_preview_holder
@onready var deck_preview = extra_screens.deck_preview_holder
@onready var geometry = extra_screens.geometry
@onready var decision_holder = extra_screens.decision_holder
@onready var card_matchup = extra_screens.card_matchup
@onready var mouse_control = extra_screens.mouse_control
@onready var paper = extra_screens.paper
@onready var turn_info = $info
@onready var locked_text = $locked_text

@onready var chat_box = $chat_box

var cards_played = []

var card_to_play

var override_index:int = -1
var set_override_with_card_selection:bool = false

var opponent_ready:bool = false

var game_log:String

var is_in_preview:bool :
	set(value):
		is_in_preview = value
		if is_in_preview:
			if game.pixelate.visible == false and game.glitch.visible == false and game.blur.visible == false:
				%darken.visible = true
			entered_preview.emit()
		else:
			if game.pixelate.visible == false and game.glitch.visible == false and game.blur.visible == false:
				%darken.visible = false
			exited_preview.emit()
var block_starting:bool = false

var pixel_timer:int = 0
var kromer:bool = false
var turn_timer:float = 0
var time_turn:bool = false :
	set(value):
		time_turn = value
		if time_turn == true:
			turn_timer = 0 

var has_shuffled:bool = false

var extra_space_played:bool = false

var override_chest:bool = false

# Bonuses to add onto the next card played
# Check to see if any of these values are not [FutureEvents._, 0, 0] when played
# Can currently only be used in pre_card_effects
var future_events:Dictionary = {
	"Pass It On" : [FutureEvents.NEXT_CARD_BONUS, [0, 0]],
	"Winter Scavenging" : [FutureEvents.NEXT_LOSS_BONUS, [0, 0]],
	"Haunt" : [FutureEvents.NEXT_CARD_PENALTY, [0, 0]],
	"Good Morning" : [FutureEvents.NEXT_CARD_BONUS, [0, 0]],
	"Fruitless Passion" : [FutureEvents.NEXT_CARD_BONUS, [0, 0]],
	"Office GIF" : [FutureEvents.NEXT_CARD_BONUS_MULTIPLIER, [0, 0]]
}
var turn_history:Dictionary = {
	"First Used Card" : [],
	"Last Used Card" : [0, 0]
}

var cash_out:bool = false

func _ready():
	card_hand.card_removed.connect(_on_card_removed)
	card_hand.card_added.connect(_on_card_added)

func _process(delta):
	if time_turn:
		turn_timer += delta

func generate_deck_preview(card_ref, exclude:Array = [-1], reason:String = ""):
	if !is_in_preview:
		is_in_preview = true
		var exported_array:Array = []
		for i in range(card_hand.cards_in_hand.size()):
			for excluded_i in exclude:
				if i != excluded_i:
					exported_array.append(card_hand.cards_in_hand[i].export())
		if card_hand.cards_in_hand.size() - exclude.size() > 0:
			deck_preview.generate_deck(exported_array, reason, card_ref)
			extra_screens.add_screen_queue(extra_screens.DECK_PREVIEW, true)
			if reason == "Extra Space" || reason == "Brands":
				extra_screens.start_showing_screens()

func play_card(card):
	if game.started && cur_stage == Stages.TURN:
		if card.stats["Ability Name"] == "Tears":
			if card_hand.cards_in_hand.size() != game.match_rules["Cards To Win"] + 1 and game.last_decision != game.get_player().side:
				return
		
		
		if card.stats["Ability Name"] == "Categorical Knowledge":
			decision_holder.generate_message("Categorical Knowledge", card)
		if card.stats["Ability Name"] == "Legal Fees":
			decision_holder.generate_message("Legal Fees", card)
		
		if card.stats["Ability Name"] == "Brands":
			generate_deck_preview(card, [card.index], "Brands")
		if card.stats["Ability Name"] == "Extra Space":
			if !extra_space_played:
				generate_deck_preview(card, [card.index], "Extra Space")
			extra_space_played = true
		
		if extra_screens.screens_to_show != []:
			await extra_screens.finished
		
		if !extra_screens.decision_holder.cancelled:
			locked_text.set_status(card.stats["Card Name"] + " Has Been Chosen")
			if set_override_with_card_selection:
				set_override_index.rpc(card.index)
			card_to_play = card
			game.get_player().lock()
			
			for daCard in card_hand.cards_in_hand:
				daCard.selected = false
			card.selected = true
			
			
			var card_export = card.export()
			
			if turn_history["First Used Card"] == []:
				turn_history["First Used Card"] = [card_export["True Attack"], card_export["True Defense"]]
			$selected.play()
			activate_locked_text.rpc(card_export)
		extra_screens.decision_holder.cancelled = false

@rpc("any_peer")
func ability_check(card_index):
	for i in range(card_hand.cards_in_hand.size()):
		if card_index == i:
			card_hand.cards_in_hand[i].ability_check()

@rpc("any_peer")
func activate_locked_text(exported_card):
	game.get_opponent().lock()
	#If Opponent is locked in but Player is not
	if !game.get_player().locked_in:
		locked_text.activate_text(exported_card)
	#If Opponent is locked in and Player is as well
	else:
		time_turn = false
		if game.manager.peer_id == 1:
			for id in game.playing_peer_ids:
				if id != 1:
					send_card.rpc_id(id)
		else:
			send_card()
		
		locked_text.clear()
		locked_text.clear.rpc()

#Sends a card to the opposing player
@rpc("any_peer")
func send_card(resend:bool = false):
	time_turn = false
	if override_index != -1:
		receive_card.rpc_id(1, card_hand.get_card_from_index(override_index).export(), future_events, Saves.battle_quiz, Saves.battle_stats, get_info())
		card_to_play = card_hand.get_card_from_index(override_index)
	if resend:
		receive_card.rpc_id(1, card_hand.return_random_card(card_to_play.index), future_events, Saves.battle_quiz, Saves.battle_stats, get_info())
	else:
		receive_card.rpc_id(1, card_to_play.export(), future_events, Saves.battle_quiz, Saves.battle_stats, get_info())

# Receives a card from the opposing player to see if they win/lose
# This is only received by the HOST
@rpc("any_peer")
func receive_card(exported_card:Dictionary, exported_future:Dictionary, exported_quiz:Dictionary, exported_stats:Dictionary, exported_battle_info:Dictionary):
	var host_attacking:bool
	
	cur_stage = Stages.POST_TURN
	
	var attacking_card:Dictionary
	var defending_card:Dictionary
	
	var attacking_info:Dictionary = {}
	var defending_info:Dictionary = {}
	
	var decision:Sides
	if exported_card["Side"] == Sides.ATTACKING:
		host_attacking = false
		attacking_card = exported_card
		defending_card = card_to_play.export()
		attacking_info["Future"] = exported_future
		defending_info["Future"] = future_events
		attacking_info["Quiz"] = exported_quiz
		defending_info["Quiz"] = Saves.battle_quiz
		attacking_info["Stats"] = exported_stats
		defending_info["Stats"] = Saves.battle_stats
		attacking_info["Info"] = exported_battle_info
		defending_info["Info"] = get_info()
	else:
		host_attacking = true
		defending_card = exported_card
		attacking_card = card_to_play.export()
		defending_info["Future"] = exported_future
		attacking_info["Future"] = future_events
		defending_info["Quiz"] = exported_quiz
		attacking_info["Quiz"] = Saves.battle_quiz
		defending_info["Stats"] = exported_stats
		attacking_info["Stats"] = Saves.battle_stats
		defending_info["Info"] = exported_battle_info
		attacking_info["Info"] = get_info()
	
	var swap_attacking:bool = false
	var swap_defending:bool = false
	if attacking_card["Ability Name"] == "Dazed and Confused":
		swap_defending = true
	if defending_card["Ability Name"] == "Dazed and Confused":
		swap_attacking = true
	
	if !has_shuffled:
		if swap_attacking:
			if defending_card["Player ID"] == game.get_player().name:
				send_card.rpc(true)
				has_shuffled = true
				return
			else:
				attacking_card = card_hand.return_random_card(attacking_card["Index"])
				has_shuffled = true
		if swap_defending:
			#If attacking card is being played by the host
			if attacking_card["Player ID"] == game.get_player().name:
				send_card.rpc(true)
				has_shuffled = true
				return
			else:
				defending_card = card_hand.return_random_card(defending_card["Index"])
				has_shuffled = true
	
	var pre_attacking:Dictionary = attacking_card.duplicate(true)
	var pre_defending:Dictionary = defending_card.duplicate(true)
	
	pre_card_effects_per_card(pre_attacking, pre_defending, attacking_info, defending_info)
	
	pre_card_effects(pre_attacking, pre_defending, attacking_info, defending_info)
	pre_card_effects(pre_defending, pre_attacking, defending_info, attacking_info)
	
	apply_next_card_bonus_multiplier(pre_attacking, attacking_info["Future"])
	apply_next_card_bonus_multiplier(pre_defending, defending_info["Future"])
	
	decision = game.turn_decider.decide_outcome(pre_attacking, pre_defending, attacking_info, defending_info)
	
	clear_future_events()
	clear_future_events.rpc()
	
	override_index = -1
	set_override_with_card_selection = false
	
	#Use the actual dictionaries for this
	if host_attacking:
		post_card_effects.rpc(attacking_card, decision, attacking_info)
		post_card_effects(defending_card, decision, defending_info)
	else:
		post_card_effects.rpc(defending_card, decision, attacking_info)
		post_card_effects(attacking_card, decision, defending_info)
	
	if host_attacking:
		passive_card_abilities.rpc(attacking_card, decision)
		passive_card_abilities(defending_card, decision)
	else:
		passive_card_abilities.rpc(defending_card, decision)
		passive_card_abilities(attacking_card, decision)
	
	#set_ready_call.rpc(opponent_ready)
	#await sync
	
	add_to_log(attacking_card, defending_card, decision)
	process_turn(decision, pre_attacking, pre_defending, host_attacking)
	process_turn.rpc(decision, pre_attacking, pre_defending, !host_attacking)

@rpc('authority')
func process_turn(decision, attacking_card, defending_card, attacking):
	
	if attacking:
		card_matchup.start(decision, attacking_card, defending_card)
		if game.strongest_card_self == {}:
			game.strongest_card_self = attacking_card
		else:
			if game.strongest_card_self["True Attack"] < attacking_card["True Attack"]:
				game.strongest_card_self = attacking_card
		if game.strongest_card_opponent == {}:
			game.strongest_card_opponent = defending_card
		else:
			if game.strongest_card_opponent["True Attack"] < defending_card["True Attack"]:
				game.strongest_card_opponent = defending_card
		if cards_played.size() == 0:
			cards_played.append(attacking_card)
		else:
			var append_card:bool = true
			for card in cards_played:
				if attacking_card["Card Number"] == card["Card Number"]:
					append_card = false
			if append_card:
				cards_played.append(attacking_card)
	else:
		card_matchup.start(decision, defending_card, attacking_card)
		if game.strongest_card_self == {}:
			game.strongest_card_self = defending_card
		else:
			if game.strongest_card_self["True Attack"] < defending_card["True Attack"]:
				game.strongest_card_self = defending_card
		if game.strongest_card_opponent == {}:
			game.strongest_card_opponent = attacking_card
		else:
			if game.strongest_card_opponent["True Attack"] < attacking_card["True Attack"]:
				game.strongest_card_opponent = attacking_card
		if cards_played.size() == 0:
			cards_played.append(defending_card)
		else:
			var append_card:bool = true
			for card in cards_played:
				if defending_card["Card Number"] == card["Card Number"]:
					append_card = false
			if append_card:
				cards_played.append(defending_card)
	
	set_ready(false)
	end_turn(decision)

@rpc("authority")
func end_turn(decision:Sides):
	var _player = game.get_player()
	var _opponent = game.get_opponent()
	
	game.last_decision = decision
	
	if !extra_screens.showing_screens:
		extra_screens.start_showing_screens()
	await extra_screens.finished
	
	cur_stage = Stages.PRE_TURN
	
	if decision != Sides.TIE:
		if decision == game.get_player().side:
			if !override_chest:
				if card_to_play.stats["Should Remove"] or card_hand.cards_in_hand.size() == 1:
					card_hand.remove_card(card_to_play.index)
				else:
					match card_to_play.stats["Ability Name"]:
						"Other Priorities":
							var bonus_attack = card_to_play.stats["True Attack"]
							var bonus_defense = card_to_play.stats["True Attack"]
							card_to_play.clear_bonuses()
							card_to_play.set_penalty_attack(card_to_play.stats["Base Attack"], "Other Priorities")
							card_to_play.set_penalty_defense(card_to_play.stats["Base Attack"], "Other Priorities")
							deck_preview.bonuses_to_add = [bonus_attack, bonus_defense]
							generate_deck_preview(card_to_play, [card_to_play.index], "Other Priorities")
	
	turn_history["Last Used Card"] = [card_to_play.stats["True Attack"], card_to_play.stats["True Defense"]]
	
	if pixel_timer > 0:
		pixel_timer -= 1
		if pixel_timer == 0:
			game.pixel_size = 1
	
	has_shuffled = false
	
	turn_ended.emit()
	
	if game.manager.connected_peer_ids != []:
		game.get_player().cards_left = card_hand.cards_in_hand.size()
	
	if !opponent_ready:
		set_ready_call.rpc()
	locked_text.set_status("WAITING ON OPPONENT")
	
	await sync
	start_turn()

@rpc("any_peer")
func start_game():
	starting_game_card_effects()
	
	start_turn()

@rpc("any_peer")
func start_turn():
	set_ready(false)
	chat_box.message_sent_in_turn = false
	var player = game.get_player()
	var _opponent = game.get_opponent()
	
	for card in card_hand.cards_in_hand:
		card.selected = false
	
	disabled_softlock_check()
	
	locked_text.clear()
	
	extra_space_played = false
	override_chest = false
	
	player.switch_side()
	_opponent.switch_side()
	player.unlock()
	_opponent.unlock()
	
	if !block_starting:
		game.turn_count += 1
	
	starting_card_effects()
	
	if !extra_screens.showing_screens:
		extra_screens.start_showing_screens()
	
	turn_started.emit()
	cur_stage = Stages.TURN
	
	
	if game.glitch_timer > 0:
		game.glitch_timer -= 1
		if game.glitch_timer <= 0:
			game.glitch.visible = false
	if game.blur_timer > 0:
		game.blur_timer -= 1
		if game.blur_timer <= 0:
			game.blur.visible = false
	
	#card_to_play = null

func disabled_softlock_check():
	if card_hand.disabled_cards.size() > 0:
		print('softlock check')
		if card_hand.cards_in_hand.size() - card_hand.disabled_cards.size() <= game.match_rules["Cards To Win"] + 1:
			var card_index = randi_range(0, card_hand.disabled_cards.size() - 1)
			print('attemping to reenable a card!')
			card_hand.disabled_cards[card_index].disabled_time = 0
			card_hand.disabled_cards[card_index].disabled = false

@rpc("any_peer")
func update_opponent(cards_left):
	game.opponent.cards_left = cards_left

func _on_card_removed():
	for card in card_hand.cards_in_hand:
		if card.stats["Ability Name"] == "Post-Mortem":
			card.add_bonus_attack(1, "Post-Mortem")
			card.add_bonus_defense(1, "Post-Mortem")
			card.apply_bonuses()
	
	update_opponent.rpc(card_hand.cards_in_hand.size())
	
	turn_info.play()
	
	if card_hand.cards_in_hand.size() == game.match_rules["Cards To Win"]:
		announce_winner.rpc(false)
		announce_winner(true)

func _on_card_added():
	game.on_opponent_card_added.rpc()

func starting_game_card_effects(specific_cards = []):
	if specific_cards == []:
		for card in card_hand.cards_in_hand:
				specific_cards.append(card)
	for card in specific_cards:
		if !card.ability_used:
			match card.stats["Ability Name"]:
				"Paranoia":
					if randi_range(1, 4) == 1:
						card.add_bonus_attack(randi_range(5, 9), "Paranoia")
					else:
						card.add_bonus_attack(randi_range(0, 4), "Paranoia")
					
					if randi_range(1, 4) == 1:
						card.add_bonus_defense(randi_range(5, 9), "Paranoia")
					else:
						card.add_bonus_defense(randi_range(0, 4), "Paranoia")
				"Enthusiast":
					var hyena_upgrades:int = Saves.battle_stats["Hyena Upgrades"]
					var hyena_attack:int = ceil(float(hyena_upgrades) / 2)
					var hyena_defense:int = floor(float(hyena_upgrades) / 2)
					card.stats["Base Attack"] = hyena_attack
					card.stats["Base Defense"] = hyena_defense
				"Worker's Revolution":
					if Saves.battle_quiz["Employment"]:
						card.add_bonus_attack(2, "Employment")
						card.add_bonus_defense(2, "Employment")
				"Debt":
					var years_attended = Saves.battle_quiz["College Years"]
					if years_attended > 0:
						card.add_penalty_attack(years_attended, "Debt")
					else:
						card.add_bonus_attack(2, "Debt")
				"Ambush Predator":
					if card.stats["Bonuses"]["Ambush Predator"] == [0, 0]:
						card.add_bonus_attack(2, "Ambush Predator")
						card.add_bonus_defense(2, "Ambush Predator")
				"Speedrun":
					if Saves.battle_quiz["Speedrun"]:
						card.add_bonus_attack(2, "Speedrun")
						card.add_bonus_defense(2, "Speedrun")
				"Leaderboard":
					var composty_attack = ceil(float(Saves.items["Composty Tokens"]) / 2)
					var composty_defense = floor(float(Saves.items["Composty Tokens"]) / 2)
					card.add_bonus_attack(composty_attack, "Leaderboard")
					card.add_bonus_defense(composty_defense, "Leaderboard")
				"The Grind":
					var login_attack = ceil(float(Saves.playerInfo["Login Streak"]) / 2)
					var login_defense = floor(float(Saves.playerInfo["Login Streak"]) / 2)
					
					login_attack = clamp(login_attack, 0, 3)
					login_defense = clamp(login_defense, 0, 3)
					
					card.add_bonus_attack(login_attack, "The Grind")
					card.add_bonus_defense(login_defense, "The Grind")
				"Molten":
					card.stats["Fire"] = true
				"Pro-Youtuber":
					card.stats["Base Attack"] = floor(float(Saves.battle_quiz["Most Views"]) / 5000.0)
					card.stats["Base Defense"] = floor(float(Saves.battle_quiz["Most Views"]) / 5000.0)
				"Hosting":
					if game.manager.game_type == game.manager.SERVER:
						card.add_bonus_attack(2, "Hosting")
						card.add_bonus_defense(2, "Hosting")

#For cards thats abilities start at the beginning of a turn
func starting_card_effects():
	time_turn = true
	for card in card_hand.cards_in_hand:
		if card.stats["Fire"] and card.stats["Ability Name"] != "Molten":
			if randi_range(1, 4) == 1:
				card_hand.remove_card(card.index)
		
		if card.stats["Fire"]:
			for i in range(2):
				var random = randi_range(1, 20) 
				if random == 1 or random == 2 or random == 3:
					if i == 0:
						if card_hand.card_exists(card.index - 1) and card_hand.get_card_from_index(card.index - 1).stats["Fire"] == false:
							card_hand.get_card_from_index(card.index - 1).stats["Fire"] = true
							card_hand.get_card_from_index(card.index - 1).set_penalty_attack(2, "Fire")
							card_hand.get_card_from_index(card.index - 1).set_penalty_defense(2, "Fire")
					elif i == 1:
						if card_hand.card_exists(card.index + 1) and card_hand.get_card_from_index(card.index + 1).stats["Fire"] == false:
							card_hand.get_card_from_index(card.index + 1).stats["Fire"] = true
							card_hand.get_card_from_index(card.index + 1).set_penalty_attack(2, "Fire")
							card_hand.get_card_from_index(card.index + 1).set_penalty_defense(2, "Fire")
		
		if !card.ability_used:
			match card.stats["Ability Name"]:
				"Price Goes Up Yearly":
					if game.get_player().side == Sides.ATTACKING:
						card.add_bonus_attack(1, "Price Goes Up Yearly")
						card.add_bonus_defense(1, "Price Goes Up Yearly")
				"No Show":
					var random = randi_range(0, 20)
					if random == 7:
						card_hand.remove_card(card.index)
				"Deadline":
					if game.get_opponent().cards_left == game.match_rules["Cards To Win"] + 1:
						card.add_bonus_attack(4, "Deadline")
						card.add_bonus_defense(4, "Deadline")
					card.ability_check()
				"Reminiscing":
					if turn_history["First Used Card"] != []:
						card.set_bonus_attack(turn_history["First Used Card"][0], "Reminiscing")
						card.set_bonus_defense(turn_history["First Used Card"][1], "Reminiscing")
				"What Day Is It?":
					if Time.get_date_dict_from_system()["weekday"] == Time.Weekday.WEEKDAY_WEDNESDAY:
						card.set_bonus_attack(1, "What Day Is It?")
						card.set_bonus_defense(1, "What Day Is It?")
				"Editing":
					global.update_save_file_time()
					if card.stats["Bonuses"]["Editing"] == [0, 0] and Saves.playerInfo["Time"] >= 5 * 60 * 60:
						card.add_bonus_attack(2, "Editing")
				"Transform":
					card.stats["Bonuses"]["Transform"] = [0, 0]
					card.set_bonus_attack(turn_history["Last Used Card"][0], "Transform")
					card.set_bonus_defense(turn_history["Last Used Card"][1], "Transform")
				"Grazing":
					if card.stats["Bonuses"]["Grazing"] != [0, 0]:
						card.set_bonus_attack(0, "Grazing")
						card.set_bonus_defense(0, "Grazing")
					if Overworld.get_current_hour() >= 12 and Overworld.get_current_hour() < 16:
						card.set_bonus_attack(2, "Grazing")
						card.set_bonus_defense(2, "Grazing")
					else:
						card.set_bonus_attack(0, "Grazing")
						card.set_bonus_defense(0, "Grazing")
				"Ambush Predator":
						if card.stats["Bonuses"]["Ambush Predator"] != [0, 0]:
							card.set_bonus_attack(0, "Ambush Predator")
							card.set_bonus_defense(0, "Ambush Predator")
				"Truest Nemo":
					if card_to_play != null:
						if card_to_play.stats["Card Series"] == "Luna":
							if card.stats["Bonuses"]["Truest Nemo"] == [0, 0]:
								card.add_bonus_attack(2, "Truest Nemo")
								card.add_bonus_defense(2, "Truest Nemo")
						else:
							card.set_bonus_attack(0, "Truest Nemo")
							card.set_bonus_defense(0, "Truest Nemo")
				"Tag-Out":
					var turn_count = game.turn_count - 1
					
					#5-1
					if turn_count % 4 == 0 or turn_count % 4 == 1:
						card.stats["Base Attack"] = 5
						card.stats["Base Defense"] = 1
					#2-3
					if turn_count % 4 == 2 or turn_count % 4 == 3:
						card.stats["Base Attack"] = 2
						card.stats["Base Defense"] = 3
				"Units":
					var attack = 0
					var defense = 0
					var new_name:String = ""
					match randi_range(1, 4):
						1:
							# NORMAL CAT
							attack = 2
							defense = 2
							new_name = "Cat"
						2:
							# TANK CAT
							attack = 1
							defense = 5
							new_name = "Tank Cat"
						3:
							# AXE CAT
							attack = 5
							defense = 1
							new_name = "Axe Cat"
						4:
							# GROSS CAT
							attack = 4
							defense = 4
							new_name = "Gross Cat"
					if randi_range(1, 50) == 21:
						attack = 9
						defense = 9
						new_name = "Superfeline"
					card.stats["Base Attack"] = attack
					card.stats["Base Defense"] = defense
					card.stats["Card Name"] = new_name
				"Crack":
					if game.turn_count > 1:
						if game.turn_count % 2 == 1:
							card.add_penalty_attack(1, "Crack")
						else:
							card.add_penalty_defense(1, "Crack")
				"Pitstop":
					if randi_range(1, 10) == 1:
						var random = randi_range(0, 128)
						var random_string:String = str(random)
						if random_string.length() == 1:
							random_string = "00" + random_string
						elif random_string.length() == 2:
							random_string = "0" + random_string
						var random_card = randi_range(0, card_hand.cards_in_hand.size() - 1)
						card_hand.replace_card(random_card, random_string, false)
				"Deception":
					if card_hand.cards_in_hand.size() < 4:
						card.stats["Card Name"] = "Pocket Watch"
						card.stats["Base Attack"] = 5
						card.stats["Base Defense"] = 5
					else:
						card.stats["Card Name"] = "Shark Meter"
						card.stats["Base Attack"] = 3
						card.stats["Base Defense"] = 3
				"Fangirl":
					for leCard in card_hand.cards_in_hand:
						if leCard.stats["Card Number"] == "134":
							if card.stats["Bonuses"]["Fangirl"] == [0, 0]:
								card.add_bonus_attack(2, "Fangirl")
								card.add_bonus_defense(2, "Fangirl")
				"Dice Roll":
					var rand_a = randi_range(1, 5)
					if rand_a == 1 or rand_a == 2:
						card.add_bonus_attack(card.stats["True Attack"], "Dice Roll")
					elif rand_a == 3:
						for bonus in card.stats["Bonuses"].keys():
							card.set_bonus_attack(0, bonus)
							card.stats["Base Attack"] = 1
					var rand_d = randi_range(1, 5)
					if rand_d == 1 or rand_d == 2:
						card.add_bonus_defense(card.stats["True Attack"], "Dice Roll")
					elif rand_d == 3:
						for bonus in card.stats["Bonuses"].keys():
							card.set_bonus_defense(0, bonus)
							card.stats["Base Defense"] = 1
				"Fronting":
					if randi_range(1, 4) == 1:
						var new_card_num = str(randi_range(153, 155))
						if randi_range(1, 100) == 1:
							new_card_num = 156
						card_hand.replace_card(card.index, new_card_num, true)
	for card in card_hand.cards_in_hand:
		card.apply_bonuses()
		card.apply_penalties()
		card.recalculate_stats()

# Called before a turn is decided. 
# This will only be called on the host, so can't do anything really permanent
# Save permanent effects for post card effects, use this to create a temporary-
# Version with the exported card
func pre_card_effects(card, affecting_card, info, affecting_info):
	# Don't use the normal match for this, as setting this earlier allows for the normal match to work for this card. 
	if card["Ability Name"] == "The Goop":
		card["Ability Name"] = affecting_card["Ability Name"]
		card["Ability Description"] = affecting_card["Ability Description"]
		card["Should Remove"] = affecting_card["Should Remove"]
		card["One Use Ability"] = affecting_card["One Use Ability"]
	
	if !card["Ability Used"]:
		match card["Ability Name"]:
			"Neuralyzer":
				affecting_card["True Attack"] = affecting_card["Base Attack"]
				affecting_card["True Defense"] = affecting_card["Base Defense"]
				
				affecting_card["Bonus Attack"] = 0
				affecting_card["Bonus Defense"] = 0
				ability_check.rpc(card["Index"])
			"Unfunny Tag":
				affecting_card["True Attack"] -= 1
				affecting_card["True Defense"] -= 1
				
				affecting_card["Penalty Attack"] += 1
				affecting_card["Penalty Defense"] += 1
				
				affecting_card["Penalties"]["Unfunny Tag"] = [1, 1]
				#ability_check.rpc(card["Index"])
			"Simping":
				if affecting_card["Card Series"] == "Dapper":
					affecting_card["True Attack"] -= 2
					affecting_card["True Defense"] -= 2
					
					affecting_card["Penalty Attack"] += 2
					affecting_card["Penalty Defense"] += 2
				
					affecting_card["Penalties"]["Simping"] = [2, 2]
			"Walk":
				if turn_timer <= 30:
					card["True Defense"] += 2
					
					card["Bonus Defense"] += 2
				
					card["Bonuses"]["Walk"] = [0, 2]
			"Bathroom Break":
				if chat_box.message_sent_in_turn:
					card["True Attack"] -= 1
					card["Penalty Attack"] += 1
					card["Penalties"]["Bathroom Break"][0] += 1
					
					card["True Defense"] -= 1
					card["Penalty Defense"] += 1
					card["Penalties"]["Bathroom Break"][1] += 1
			"Awesome Ogre":
				if affecting_card["Card Series"] == "Block":
					affecting_card["True Attack"] += 2
					affecting_card["Bonus Attack"] += 2
					card["Bonuses"]["Awesome Ogre"][0] += 2
					
					card["True Defense"] += 2
					card["Bonus Defense"] += 2
					card["Bonuses"]["Awesome Ogre"][1] += 2
			"Take Batteries":
				card["True Defense"] += 1
				card["Bonus Defense"] += 1
				card["Bonuses"]["Take Batteries"][1] += 1
				
				affecting_card["True Attack"] -= 1
				affecting_card["Penalty Attack"] += 1
				affecting_card["Penalties"]["Take Batteries"][0] += 1
			"Brainrot":
				affecting_card["True Attack"] -= 1
				affecting_card["True Defense"] -= 1
				
				affecting_card["Penalty Attack"] += 1
				affecting_card["Penalty Defense"] += 1
				
				affecting_card["Penalties"]["Brainrot"][0] += 1
				affecting_card["Penalties"]["Brainrot"][1] += 1
			"Angry and Senile":
				if affecting_info["Quiz"]["Age"] < 18:
					if card["Bonuses"]["Minors DNI"] == [0, 0]:
						card["True Attack"] += 3
						card["Bonus Attack"] += 3
						card["Bonuses"]["Minors DNI"][0] += 3
						
						card["True Defense"] -= 1
						card["Penalty Defense"] += 1
						card["Penalties"]["Minors DNI"][1] += 1
			"Last Live: 3 Months Ago":
				if affecting_info["Quiz"]["Twitch"]:
					if card["Penalties"]["Last Live: 3 Months Ago"] == [0, 0]:
						card["True Attack"] -= 2
						card["Penalty Attack"] += 2
						card["Penalties"]["Last Live: 3 Months Ago"][0] += 2
			"Effort Tag":
				if affecting_info["Quiz"]["Object Show"]:
					if card["Penalties"]["Effort Tag"] == [0, 0]:
						card["True Attack"] -= 1
						card["Penalty Attack"] += 1
						card["Penalties"]["Effort Tag"][0] += 1
						
						card["True Defense"] -= 1
						card["Penalty Defense"] += 1
						card["Penalties"]["Effort Tag"][1] += 1
			"Awareness":
				var participated = false
				if affecting_info["Quiz"]["Server Member"] == "Wibr" or affecting_info["Quiz"]["Server Member"] == "SJ" or affecting_info["Quiz"]["Server Member"] == "Cleft" or affecting_info["Quiz"]["Server Member"] == "Luna" or affecting_info["Quiz"]["Server Member"] == "Cost":
					participated = true
				if participated:
					if card["Bonuses"]["Awareness"] == [0, 0]:
						card["True Attack"] += 2
						card["Bonus Attack"] += 2
						card["Bonuses"]["Awareness"][0] += 2
			"Top 100":
				if info["Quiz"]["Subscribers"] > affecting_info["Quiz"]["Subscribers"]:
					if card["Bonuses"]["Top 100"] == [0, 0]:
						card["True Attack"] += 2
						card["Bonus Attack"] += 2
						card["Bonuses"]["Top 100"][0] += 2
						
						card["True Defense"] += 2
						card["Bonus Defense"] += 2
						card["Bonuses"]["Top 100"][1] += 2
			"Spreadsheet":
				var average = float(info["Stats"]["Wins"]) / float(info["Stats"]["Losses"])
				var affecting_average = float(affecting_info["Stats"]["Wins"]) / float(affecting_info["Stats"]["Losses"])
				if average > affecting_average:
					card["True Attack"] += 2
					card["Bonus Attack"] += 2
					card["Bonuses"]["Spreadsheet"][0] += 2
			"Double It And Pass It To The Next Person":
				card["True Attack"] -= card["Bonus Attack"]
				card["True Defense"] -= card["Bonus Defense"]
				card["Bonus Attack"] = 0
				card["Bonus Defense"] = 0
				for key in card["Bonuses"].keys():
					card["Bonuses"][key] = [0, 0]
				for key in card["Penalties"].keys():
					card["Penalties"][key] = [0, 0]
			"Three Handed":
				if randi_range(1, 2) == 1:
					card["True Attack"] += 2
					card["Bonus Attack"] += 2
					card["Bonuses"]["Three Handed"][0] += 2
				else:
					card["True Defense"] += 2
					card["Bonus Defense"] += 2
					card["Bonuses"]["Three Handed"][1] += 2
			"Dance":
				if affecting_info["Info"]["Victory Chest"] > info["Info"]["Victory Chest"]:
					card["True Attack"] += 2
					card["Bonus Attack"] += 2
					card["Bonuses"]["Dance"][0] += 2
					
					card["True Defense"] += 2
					card["Bonus Defense"] += 2
					card["Bonuses"]["Dance"][1] += 2
			"Denmark":
				if affecting_info["Quiz"]["Country"] != info["Quiz"]["Country"]:
					card["True Attack"] += 2
					card["Bonus Attack"] += 2
					card["Bonuses"]["Denmark"][0] += 2
			"Donkey Kong":
				if affecting_card["Is Human"]:
					card["True Attack"] -= 1
					card["Penalty Attack"] += 1
					card["Penalties"]["Donkey Kong"][0] += 1
					
					card["True Defense"] -= 1
					card["Penalty Defense"] += 1
					card["Penalties"]["Donkey Kong"][1] += 1
# Not the best way to do this, but it stops the code being jumbled in the function already.
# Similar to pre card effects, except not called twice
func pre_card_effects_per_card(attacking_card, defending_card, attacking_info, defending_info):
	apply_next_card_bonus(attacking_card, attacking_info["Future"])
	apply_next_card_bonus(defending_card, defending_info["Future"])
	
	#You gotta add the code for the abilities TWICE!!!!!!
	match attacking_card["Ability Name"]:
		"Wrong Terminal":
			var attacking_attack = attacking_card["True Attack"]
			var attacking_defense = attacking_card["True Defense"]
			var attacking_base_attack = attacking_card["Base Attack"]
			var attacking_base_defense = attacking_card["Base Defense"]
			var attacking_bonus_attack = attacking_card["Bonus Attack"]
			var attacking_bonus_defense = attacking_card["Bonus Defense"]
			var attacking_penalty_attack = attacking_card["Penalty Attack"]
			var attacking_penalty_defense = attacking_card["Penalty Defense"]
			var attacking_bonuses = attacking_card["Bonuses"]
			var attacking_penalties = attacking_card["Penalties"]
			
			attacking_card["True Attack"] = defending_card["True Attack"]
			attacking_card["True Defense"] = defending_card["True Defense"]
			attacking_card["Base Attack"] = defending_card["Base Attack"]
			attacking_card["Base Defense"] = defending_card["Base Defense"]
			attacking_card["Bonus Attack"] = defending_card["Bonus Attack"]
			attacking_card["Bonus Defense"] = defending_card["Bonus Defense"]
			attacking_card["Penalty Attack"] = defending_card["Penalty Attack"]
			attacking_card["Penalty Defense"] = defending_card["Penalty Defense"]
			attacking_card["Penalties"] = defending_card["Penalties"]
			attacking_card["Bonueses"] = defending_card["Bonuses"]
			
			defending_card["True Attack"] = attacking_attack
			defending_card["True Defense"] = attacking_defense
			defending_card["Base Attack"] = attacking_base_attack
			defending_card["Base Defense"] = attacking_base_defense
			defending_card["Bonus Attack"] = attacking_bonus_attack
			defending_card["Bonus Defense"] = attacking_bonus_defense
			defending_card["Penalty Attack"] = attacking_penalty_attack
			defending_card["Penalty Defense"] = attacking_penalty_defense
			defending_card["Penalties"] = attacking_penalties
			defending_card["Bonueses"] = attacking_bonuses
	
	match defending_card["Ability Name"]:
		"Wrong Terminal":
			var defending_attack = defending_card["True Attack"]
			var defending_defense = defending_card["True Defense"]
			var defending_base_attack = defending_card["Base Attack"]
			var defending_base_defense = defending_card["Base Defense"]
			var defending_bonus_attack = defending_card["Bonus Attack"]
			var defending_bonus_defense = defending_card["Bonus Defense"]
			var defending_penalty_attack = defending_card["Penalty Attack"]
			var defending_penalty_defense = defending_card["Penalty Defense"]
			var defending_bonuses = defending_card["Bonuses"]
			var defending_penalties = defending_card["Penalties"]
			
			defending_card["True Attack"] = attacking_card["True Attack"]
			defending_card["True Defense"] = attacking_card["True Defense"]
			defending_card["Base Attack"] = attacking_card["Base Attack"]
			defending_card["Base Defense"] = attacking_card["Base Defense"]
			defending_card["Bonus Attack"] = attacking_card["Bonus Attack"]
			defending_card["Bonus Defense"] = attacking_card["Bonus Defense"]
			defending_card["Penalty Attack"] = attacking_card["Penalty Attack"]
			defending_card["Penalty Defense"] = attacking_card["Penalty Defense"]
			defending_card["Penalties"] = attacking_card["Penalties"]
			defending_card["Bonueses"] = attacking_card["Bonuses"]
			
			attacking_card["True Attack"] = defending_attack
			attacking_card["True Defense"] = defending_defense
			attacking_card["Base Attack"] = defending_base_attack
			attacking_card["Base Defense"] = defending_base_defense
			attacking_card["Bonus Attack"] = defending_bonus_attack
			attacking_card["Bonus Defense"] = defending_bonus_defense
			attacking_card["Penalty Attack"] = defending_penalty_attack
			attacking_card["Penalty Defense"] = defending_penalty_defense
			attacking_card["Penalties"] = defending_penalties
			attacking_card["Bonueses"] = defending_bonuses
@rpc("authority")
func post_card_effects(opposing_card, decision, opposing_info):
	if card_to_play.stats["Ability Name"] == "The Goop":
		card_to_play.stats["Ability Name"] = opposing_card["Ability Name"]
		card_to_play.stats["Ability Description"] = opposing_card["Ability Description"]
		card_to_play.stats["Should Remove"] = opposing_card["Should Remove"]
		card_to_play.stats["One Use Ability"] = opposing_card["One Use Ability"]
	
	# Abilities that affect the OPPOSING player
	if !opposing_card["Ability Used"]:
		match opposing_card["Ability Name"]:
			"Neuralyzer":
				for card in card_hand.cards_in_hand:
					card.clear_bonuses()
			"Owner Perms":
				if decision == opposing_card["Side"]:
					await turn_started
					card_hand.disable_card(card_to_play.index, 2)
			"Strategist":
				var random_card = card_to_play
				while random_card == card_to_play:
					random_card = card_hand.cards_in_hand[randi_range(0, card_hand.cards_in_hand.size() - 1)]
				card_preview.generate_preview_from_export.rpc(random_card.export(), "Atlas's Preview of your opponent's card!", true)
				await turn_started
				card_preview.timer.start()
			"Kindness":
				if decision == opposing_card["Side"]:
					card_to_play.add_bonus_attack(2, "Kindness")
					card_to_play.add_bonus_defense(2, "Kindness")
			"Torrenting":
				if decision == game.get_player().side:
					var index = randi_range(0, card_hand.cards_in_hand.size() - 1)
					while index == card_to_play.index:
						index = randi_range(0, card_hand.cards_in_hand.size() - 1)
					
					# NEEDS STATUS MESSAGE
					
					card_hand.add_card.rpc(card_hand.get_card_from_index(index).export(), true)
					card_hand.remove_card(index)
			"Clean Timeline":
				await turn_started
				if decision == opposing_card["Side"]:
					for i in range(floor(float(card_hand.cards_in_hand.size()) / 2.0)):
						var index:int = randi_range(0, card_hand.cards_in_hand.size() - 1)
						while card_hand.get_card_from_index(index).disabled == true:
							index = randi_range(0, card_hand.cards_in_hand.size() - 1)
						card_hand.disable_card(index, 2)
			"Acidic":
				if decision == opposing_card["Side"]:
					for card in card_hand.cards_in_hand:
						card.add_penalty_defense(1, "Acidic")
			"SO RETRO!":
				await turn_started
				set_pixel_effect(7, 4)
			"Haunt":
				if decision == game.get_player().side:
					future_events["Haunt"] = [FutureEvents.NEXT_CARD_PENALTY, [2, 0]]
			"Strike":
				await turn_started
				if randi_range(1, 4) == 1:
					var exception = randi_range(0, card_hand.cards_in_hand.size() - 1)
					while exception == card_to_play.index:
						exception = randi_range(0, card_hand.cards_in_hand.size() - 1)
					for i in range(card_hand.cards_in_hand.size()):
						if i != exception:
							card_hand.disable_card(i, 2)
			"Dead Server":
				await turn_started
				card_to_play.send_card_status("Ability Removed!")
				card_to_play.stats["Ability Name"] = ""
				card_to_play.stats["Ability Description"] = ""
				card_to_play.stats["One Use Ability"] = false
				card_to_play.stats["Should Remove"] = true
				card_to_play.stats["Hide Stats"] = false
			"Scrap":
				paper.generate_crumple()
				card_to_play.ability_check()
			"Untrustworthiness":
				locked_text.show_ability = false
				locked_text.show_stats = false
				locked_text.ability_timer = 0
				locked_text.stats_timer = 0
			"Curse":
				geometry.start()
				geometry.answered.connect(
					func (correct):
						if !correct:
							var rand1 = randi_range(0, card_hand.cards_in_hand.size() - 1)
							if card_hand.cards_in_hand.size() > 1:
								while rand1 == card_to_play.index:
									rand1 = randi_range(0, card_hand.cards_in_hand.size() - 1)
							card_hand.disable_card(rand1, 2)
							if card_hand.cards_in_hand.size() > 1:
								var rand2 = randi_range(0, card_hand.cards_in_hand.size() - 1)
								if card_hand.cards_in_hand.size() > 2:
									while rand2 == rand1 or rand2 == card_to_play.index:
										rand2 = randi_range(0, card_hand.cards_in_hand.size() - 1)
								card_hand.disable_card(rand2, 2)
								if card_hand.cards_in_hand.size() > 2:
									var rand3 = randi_range(0, card_hand.cards_in_hand.size() - 1)
									if card_hand.cards_in_hand.size() > 3:
										while rand3 == rand1 or rand3 == rand2 or rand1 == card_to_play.index:
											rand3 = randi_range(0, card_hand.cards_in_hand.size() - 1)
									card_hand.disable_card(rand3, 2)
				)
				ability_check.rpc(opposing_card["Index"])
			"Take Batteries":
				card_to_play.add_penalty_attack(1, "Take Batteries")
			"Distracted":
				#NEEDS STATUS
				if decision == opposing_card["Side"]:
					for card in card_hand.cards_in_hand:
						card.stats["Ability Description"] = ""
				ability_check.rpc(opposing_card["Index"])
			".":
				await turn_started
				opposing_card["Ability Used"] = true
				if game.match_rules["Cards To Win"] == 0:
					opposing_card["Base Attack"] = 2
					opposing_card["Base Defense"] = 2
					card_hand.add_card(opposing_card, false)
				else:
					card_hand.add_card(opposing_card, false, false)
			"Insults":
				if decision == opposing_card["Side"]:
					card_to_play.add_penalty_attack(2, "Insults")
					card_to_play.add_penalty_defense(2, "Insults")
			"Thief":
				await turn_started
				if decision == opposing_card["Side"]:
					card_hand.replace_card(card_to_play.index, "-123", false)
			"Null Reference":
				await turn_started
				game.get_node("non-light-affected/Glitch").visible = true
				game.glitch_timer = 3
			"Foliage":
				await turn_started
				var ability_packed_array = []
				for card in card_hand.cards_in_hand:
					ability_packed_array.append([card.stats["Ability Name"], card.stats["Ability Description"], card.stats["One Use Ability"], card.stats["Should Remove"], card.stats["Hide Stats"]])
				ability_packed_array.shuffle()
				for i in card_hand.cards_in_hand.size():
					card_hand.cards_in_hand[i].stats["Ability Name"] = ability_packed_array[i][0]
					card_hand.cards_in_hand[i].stats["Ability Description"] = ability_packed_array[i][1]
					card_hand.cards_in_hand[i].stats["One Use Ability"] = ability_packed_array[i][2]
					card_hand.cards_in_hand[i].stats["Should Remove"] = ability_packed_array[i][3]
					card_hand.cards_in_hand[i].stats["Hide Stats"] = ability_packed_array[i][4]
					card_hand.cards_in_hand[i].send_card_status("Ability Changed!")
				ability_check.rpc(opposing_card["Index"])
			"Telekenesis":
				mouse_control.enabled = true
				mouse_control.enabled_timer = 3
			"I Am The Xenomorph!":
				if decision == game.get_player().side:
					override_chest = true
			"Comments":
				for card in card_hand.cards_in_hand:
					if card.stats["True Attack"] > 3:
						card.add_penalty_attack(1, "Comments")
					if card.stats["True Defense"] > 3:
						card.add_penalty_defense(1, "Comments")
				ability_check.rpc(opposing_card["Index"])
			"False Identity":
				extra_screens.card_matchup.hide_opposing = true
			"Shadows":
				await turn_started
				Overworld.set_time((10 + 12) * 60 * 60)
			"Goggles":
				await turn_started
				game.get_node("non-light-affected/Blur").visible = true
				game.blur_timer = 3
			"Magic":
				if decision == opposing_card["Side"]:
					await turn_started
					var cards = []
					for num in range(card_hand.cards_in_hand.size()):
						num = randi_range(0, 156)
						for daNum in cards:
							while num == daNum:
								num = randi_range(0, 156)
						cards.append(num)
					
					var string_cards = []
					for num in cards:
						var string_num:String
						if str(num).length() == 1:
							string_num = "00" + str(num)
						if str(num).length() == 2:
							string_num = "0" + str(num)
						if str(num).length() == 3:
							string_num = str(num)
						string_cards.append(string_num)
					
					card_hand.reindex_deck()
					for i in range(card_hand.cards_in_hand.size()):
						card_hand.replace_card(i, string_cards[i], true)
				update_opponent.rpc(card_hand.cards_in_hand.size())
	
	#Abilities of the PLAYER's card
	if !card_to_play.ability_used:
		match card_to_play.stats["Ability Name"]:
			"The 1K Race":
				await turn_started
				if decision == opposing_card["Side"] and card_hand.removed_cards.size() > 0:
					card_hand.readd_card(randi_range(0, card_hand.removed_cards.size() - 1))
			"Boost":
				for card in card_hand.cards_in_hand:
					if card != card_to_play:
						card.add_bonus_defense(1, "Boost")
				card_to_play.ability_check()
			"Catalyst":
				if decision == game.get_player().side:
					generate_deck_preview(card_to_play, [card_to_play.index], "Catalyst")
			"Gamer Rage":
				if decision == opposing_card["Side"]:
					card_to_play.add_bonus_attack(2, "Gamer Rage")
					card_to_play.ability_check()
			"Radio Broadcast":
				locked_text.show_stats = true
				locked_text.stats_timer = 4
			"Pass It On":
				if decision == opposing_card["Side"]:
					future_events["Pass It On"] = [FutureEvents.NEXT_CARD_BONUS, [floor(float(card_to_play.stats["True Attack"]) / 2), floor(float(card_to_play.stats["True Defense"]) / 2)]]
			"Generic Response":
				for card in card_hand.cards_in_hand:
					if card.stats["Ability Name"] == "" or card.stats["Ability Name"] == " ":
						card.add_bonus_attack(3, "Generic Response")
						card.add_bonus_defense(3, "Generic Response")
				card_to_play.ability_check()
			"Cash Out":
				for card in card_hand.cards_in_hand:
					if card.stats["True Attack"] <= 3:
						card.add_bonus_attack(2, "Cash Out")
					if card.stats["True Defense"] <= 3:
						card.add_bonus_defense(2, "Cash Out")
				card_to_play.ability_check()
			"Torrenting":
				if decision == opposing_card["Side"]:
					# NEEDS STATUS MESSAGE
					card_hand.add_card.rpc(card_to_play.export(), true)
					card_hand.remove_card(card_to_play.index, false, true, true)
			"All Powerful":
				card_to_play.add_penalty_attack(1, "All Powerful")
				card_to_play.add_penalty_defense(1, "All Powerful")
			"The HUD":
				locked_text.show_ability = true
				locked_text.ability_timer = 4
			"Winter Scavenging":
				future_events["Winter Scavenging"] = [FutureEvents.NEXT_LOSS_BONUS, [2, 2]]
			"Fear of God":
				var fate = randi_range(1, 5)
				if fate == 1:
					card_hand.remove_all_cards()
				else:
					card_hand.remove_all_cards.rpc()
				block_start()
				block_start.rpc()
			"Nectar of the Gods":
				for card in card_hand.cards_in_hand:
					if randi_range(0, 1) == 0:
						card.add_bonus_attack(1, "Nectar of the Gods")
					else:
						card.add_bonus_defense(1, "Nectar of the Gods")
				card_to_play.ability_check()
			"Kromer":
				kromer = true
			"Wrong Terminal":
				card_to_play.stats["Bonuses"] = opposing_card["Bonuses"]
				card_to_play.stats["Penalties"] = opposing_card["Penalties"]
				card_to_play.stats["Base Attack"] = opposing_card["Base Attack"]
				card_to_play.stats["Base Defense"] = opposing_card["Base Defense"]
				card_to_play.stats["Can Get Bonuses"] = opposing_card["Can Get Bonuses"]
				ability_check(card_to_play.index)
			"Good Morning":
				future_events["Good Morning"] = [FutureEvents.NEXT_CARD_BONUS, [0, 3]]
			"Take Batteries":
				card_to_play.add_bonus_defense(1, "Take Batteries")
			"Angry and Senile":
				if opposing_info["Quiz"]["Age"] < 18:
					card_to_play.add_bonus_attack(3, "Angry and Senile")
					card_to_play.add_penalty_defense(1, "Angry and Senile")
					card_to_play.ability_check()
			"Fruitless Passion":
				if Saves.battle_quiz["Projects"]:
					future_events["Fruitless Passion"] = [FutureEvents.NEXT_CARD_BONUS, [1, 1]]
			"Effort Tag":
				if opposing_info["Quiz"]["Object Show"]:
					if card_to_play.stats["Penalties"]["Effort Tag"] == [0, 0]:
						card_to_play.add_penalty_attack(1, "Effort Tag")
						card_to_play.add_penalty_defense(1, "Effort Tag")
						card_to_play.ability_check()
			"Awareness":
				var participated:bool = false
				if opposing_info["Quiz"]["Server Member"] == "Wibr" or opposing_info["Quiz"]["Server Member"] == "SJ" or opposing_info["Quiz"]["Server Member"] == "Cleft" or opposing_info["Quiz"]["Server Member"] == "Luna" or opposing_info["Quiz"]["Server Member"] == "Cost":
					participated = true
				if participated:
					if card_to_play.stats["Bonuses"]["Awareness"] == [0, 0]:
						card_to_play.add_bonus_attack(2, "Awareness")
						card_to_play.ability_check()
			"Top 100":
				var own = Saves.battle_quiz["Subscribers"]
				var opposing = opposing_info["Quiz"]["Subscribers"]
				if own > opposing:
					card_to_play.add_bonus_attack(2, "Top 100")
					card_to_play.add_bonus_defense(2, "Top 100")
					card_to_play.ability_check()
			'Office GIF':
				future_events["Office GIF"] = [FutureEvents.NEXT_CARD_BONUS_MULTIPLIER, [2, 2]]
				card_to_play.ability_check()
			".":
				await turn_started
				card_hand.remove_card(card_to_play.index, false, true, false)
			"Charity":
				for card in card_hand.cards_in_hand:
					if card != card_to_play:
						card.add_bonus_attack(card_to_play.get_bonus_attack(), "Charity")
						card.add_bonus_defense(card_to_play.get_bonus_defense(), "Charity")
				card_to_play.ability_check()
			"Double It And Pass It To The Next Person":
				future_events["Double It And Pass It To The Next Person"] = [FutureEvents.NEXT_CARD_BONUS, [card_to_play.get_bonus_attack(), card_to_play.get_bonus_defense()]]
				for key in card_to_play.stats["Bonuses"].keys():
					card_to_play.set_bonus_attack(0, key)
					card_to_play.set_bonus_defense(0, key)
				for key in card_to_play.stats["Penalties"].keys():
					card_to_play.set_penalty_attack(0, key)
					card_to_play.set_penalty_defense(0, key)
			"Presidential Pardon":
				for card in card_hand.cards_in_hand:
					if card != card_to_play:
						for penalty in card.stats["Penalties"]:
							if card.stats["Penalties"][penalty][0] > 1:
								card.add_penalty_attack(-1, penalty)
							if card.stats["Penalties"][penalty][1] > 1:
								card.add_penalty_defense(-1, penalty)
				card_to_play.ability_check()
			"Voltage":
				await turn_started
				if decision == opposing_card["Side"]:
					var half_of_deck:int = floor(float(card_hand.cards_in_hand.size()) / 2)
					var indexes_to_disable = []
					for i in range(half_of_deck):
						var index = randi_range(0, card_hand.cards_in_hand.size() - 1)
						for leIndex in indexes_to_disable:
							while index == leIndex:
								index = randi_range(0, card_hand.cards_in_hand.size() - 1)
						indexes_to_disable.append(index)
					for index in indexes_to_disable:
						card_hand.disable_card(index, 3)
			"Deceiver":
				set_override_with_card_selection = true
			"Annoying":
				if decision == game.get_player().side:
					generate_deck_preview(card_to_play, [card_to_play.index], "Annoying")
			"Denmark":
				if Saves.battle_quiz["Country"] != opposing_info["Quiz"]["Country"] and card_to_play.stats["Bonuses"]["Denmark"] == [0, 0]:
					card_to_play.add_bonus_attack(2, "Denmark")
			"I Am The Xenomorph!":
				if decision == opposing_card["Side"]:
					card_hand.remove_card(card_to_play.index)
			"Magic":
				if decision == game.get_player().side:
					await turn_started
					var cards = []
					for num in range(card_hand.cards_in_hand.size()):
						num = randi_range(0, 156)
						for daNum in cards:
							while num == daNum:
								num = randi_range(0, 156)
						cards.append(num)
					
					var string_cards = []
					for num in cards:
						var string_num:String
						if str(num).length() == 1:
							string_num = "00" + str(num)
						if str(num).length() == 2:
							string_num = "0" + str(num)
						if str(num).length() == 3:
							string_num = str(num)
						string_cards.append(string_num)
					
					card_hand.reindex_deck()
					for i in range(card_hand.cards_in_hand.size()):
						card_hand.replace_card(i, string_cards[i], true)
					update_opponent.rpc(card_hand.cards_in_hand.size())
			"False Identity":
				extra_screens.card_matchup.hide_self = true
	
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_LOSS_BONUS and decision == opposing_card["Side"] and future_events[key][1] != [0, 0]:
			card_to_play.add_bonus_attack(future_events[key][1][0], key)
			card_to_play.add_bonus_defense(future_events[key][1][1], key)
			future_events[key][1] = [0, 0]
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_LOSS_PENALTY and decision == opposing_card["Side"] and future_events[key][1] != [0, 0]:
			card_to_play.add_penalty_attack(future_events[key][1][0], key)
			card_to_play.add_penalty_defense(future_events[key][1][1], key)
			future_events[key][1] = [0, 0]
#Called at the end of every turn for EVERY card in your hand. 
@rpc("authority")
func passive_card_abilities(_opposing_card, decision):
	for card in card_hand.cards_in_hand:
		match card.stats["Ability Name"]:
			"Revenge Shot":
				if decision != game.get_player().side and decision != Sides.TIE:
					if card.stats["Bonuses"]["Revenge Shot"] == [0, 0]:
						card.add_bonus_attack((card.stats["True Attack"] * 2) - card.stats["Base Attack"], "Revenge Shot")
						card.add_bonus_defense((card.stats["True Defense"] * 2)  - card.stats["Base Defense"], "Revenge Shot")
				else:
					card.set_bonus_attack(0, "Revenge Shot")
					card.set_bonus_defense(0, "Revenge Shot")
			"Up and Coming":
				if decision == game.get_player().side:
					card.add_bonus_attack(1, "Up and Coming")
					card.add_bonus_defense(1, "Up and Coming")
				elif decision == game.get_opponent().side:
					card.set_bonus_attack(0, "Up and Coming")
					card.set_bonus_defense(0, "Up and Coming")
			"Speeding":
				if decision == game.get_player().side:
					if card.favor == false:
						card.add_bonus_attack(1, "Speeding")
						card.add_penalty_defense(1, "Speeding")
					else:
						card.add_bonus_defense(1, "Speeding")
						card.add_penalty_attack(1, "Speeding")
			"Rising":
				await turn_started
				card.set_bonus_attack(0, "Rising")
				card.set_bonus_defense(0, "Rising")
				card.apply_bonuses()
				card.apply_penalties()
				card.add_bonus_attack(card.get_bonus_attack(), "Rising")
				card.add_bonus_defense(card.get_bonus_defense(), "Rising")




@rpc("authority")
func clear_future_events():
	#Clear future events as this will set them?
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_CARD_BONUS or future_events[key][0] == FutureEvents.NEXT_CARD_PENALTY or future_events[key][0] == FutureEvents.NEXT_CARD_BONUS_MULTIPLIER or future_events[key][0] == FutureEvents.NEXT_CARD_PENALTY_MULTIPLIER:
			future_events[key][1] = [0, 0]
func apply_next_card_bonus(card, le_future_events):
	for key in le_future_events.keys():
		if le_future_events[key][0] == FutureEvents.NEXT_CARD_BONUS and le_future_events[key][1] != [0, 0]:
			card["True Attack"] += le_future_events[key][1][0]
			card["True Defense"] += le_future_events[key][1][1]
			card["Bonus Attack"] += le_future_events[key][1][0]
			card["Bonus Defense"] += le_future_events[key][1][1]
			card["Bonuses"][key] = le_future_events[key][1]
		if le_future_events[key][0] == FutureEvents.NEXT_CARD_PENALTY and le_future_events[key][1] != [0, 0]:
			card["True Attack"] -= le_future_events[key][1][0]
			card["True Defense"] -= le_future_events[key][1][1]
			card["Penalty Attack"] += le_future_events[key][1][0]
			card["Penalty Defense"] += le_future_events[key][1][1]
			card["Penalties"][key] = le_future_events[key][1]
func apply_next_card_bonus_multiplier(card, le_future_events):
	for key in le_future_events.keys():
		if le_future_events[key][0] == FutureEvents.NEXT_CARD_BONUS_MULTIPLIER and future_events[key][1] != [0, 0]:
			var ability_name = card["Ability Name"]
			var bonus_amount = card["Bonuses"][ability_name]
			var multiplier = le_future_events[key][1]
			
			card["Bonuses"][ability_name][0] *= le_future_events[key][1][0]
			card["Bonuses"][ability_name][1] *= le_future_events[key][1][1]
			card["True Attack"] += bonus_amount[0] * multiplier[0]
			card["True Defense"] += bonus_amount[1] * multiplier[1]
			card["Bonus Attack"] += bonus_amount[0] * multiplier[0]
			card["Bonus Defense"] += bonus_amount[1] * multiplier[1]


@rpc("any_peer")
func set_override_index(value:int):
	override_index = value
	send_card()

func get_info():
	var dict = {}
	dict["Victory Chest"] = card_hand.victory_chest.get_children().size()
	return dict

@rpc("any_peer")
func add_bonus_attack(index, amount, reason):
	card_hand.get_card_from_index(index).add_bonus_attack(amount, reason)

@rpc("any_peer")
func add_bonus_defense(index, amount, reason):
	card_hand.get_card_from_index(index).add_bonus_defense(amount, reason)

@rpc("any_peer")
func set_ready_call():
	if extra_screens.showing_screens:
		await extra_screens.finished
	opponent_ready = true
	set_ready.rpc(true)
	emit_sync.rpc()
@rpc("any_peer")
func set_ready(val):
	opponent_ready = val
@rpc("any_peer")
func emit_sync():
	sync.emit()

@rpc("any_peer")
func announce_winner(has_won:bool):
	if cur_stage == Stages.POST_TURN:
		await turn_started
	if has_won:
		print(game.get_player().player_name + " HAS WON THE GAME!")
	else:
		print(game.get_opponent().player_name + " HAS WON THE GAME!")
	
	block_start()
	block_start.rpc()
	
	game.music_player.stop()
	extra_screens.results.create(has_won)

func set_pixel_effect(pixels, duration):
	game.pixel_size = pixels
	pixel_timer = duration

func add_to_log(attacking_card:Dictionary, defending_card:Dictionary, decision:Sides):
	var addition:String = ""
	addition += "--------------------------------------------------\n"
	addition += "TURN NUMBER " + str(game.turn_count) + "\n\n"
	addition += "ATTACKING CARD:\n" 
	for key in attacking_card.keys():
		if key != "Bonuses" and key != "Penalties":
			addition += "\t" + key + ": " + str(attacking_card[key]) + "\n"
		else:
			addition += "\t" + key + ": \n"
			for daKey in attacking_card[key].keys():
				addition += "\t\t" + daKey + ": " + str(attacking_card[key][daKey]) + "\n"
	addition += "\n"
	addition += "DEFENDING CARD:\n" 
	for key in defending_card.keys():
		if key != "Bonuses" and key != "Penalties":
			addition += "\t" + key + ": " + str(defending_card[key]) + "\n"
		else:
			addition += "\t" + key + ": \n"
			for daKey in defending_card[key].keys():
				addition += "\t\t" + daKey + ": " + str(defending_card[key][daKey]) + "\n"
	addition += "\n"
	addition += "WINNING SIDE: "
	if decision == Sides.ATTACKING:
		addition += "ATTACKING"
	elif decision == Sides.DEFENDING:
		addition += "DEFENDING"
	elif decision == Sides.TIE:
		addition += "TRUE TIE"
	else:
		addition += "ERROR! DECISION NOT STATED IN UI.SIDES ENUM!!"
	addition += "\n\n"
	addition += "--------------------------------------------------\n\n\n"
	game_log += addition
	
	var file = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	file.store_line(game_log)

@rpc("any_peer")
func block_start():
	block_starting = true
