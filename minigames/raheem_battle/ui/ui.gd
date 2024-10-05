extends Control

signal turn_started
signal turn_ended

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
		match value:
			Stages.PRE_TURN:
				print("ENTERING PRE-TURN")
			Stages.TURN:
				print("ENTERING TURN")
			Stages.POST_TURN:
				print("ENTERING POST-TURN")

@onready var game = get_parent()

@onready var card_hand = $card_hand
@onready var extra_screens = $extra_screens
@onready var card_preview = extra_screens.card_preview_holder
@onready var deck_preview = extra_screens.deck_preview_holder
@onready var geometry = extra_screens.geometry
@onready var decision_holder = extra_screens.decision_holder
@onready var card_matchup = extra_screens.card_matchup
@onready var mouse_control = extra_screens.mouse_control
@onready var paper = extra_screens.paper
@onready var locked_text = $locked_text

var cards_to_generate = ["1", "062", "084", "082", "097", "098", "099", "100"]
var card_to_play

var override_index:int = -1
var set_override_with_card_selection:bool = false

var opponent_ready:bool = true

var game_log:String

var is_in_preview:bool :
	set(value):
		is_in_preview = value
		if is_in_preview:
			%darken.visible = true
		else:
			%darken.visible = false

var pixel_timer:int = 0
var kromer:bool = false
var turn_timer:float = 0
var time_turn:bool = false :
	set(value):
		time_turn = value
		if time_turn == true:
			turn_timer = 0 

var has_shuffled:bool = false

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
	"First Used Card" : [0, 0],
	"Last Used Card" : [0, 0]
}

var cash_out:bool = false

func _ready():
	card_hand.card_removed.connect(_on_card_removed)
	game.game_started.connect(starting_game_card_effects)

func _process(delta):
	if time_turn:
		turn_timer += delta

func generate_deck_preview(exclude:Array = [-1], reason:String = ""):
	if !is_in_preview:
		is_in_preview = true
		var exported_array:Array = []
		for i in range(card_hand.cards_in_hand.size()):
			for excluded_i in exclude:
				if i != excluded_i:
					exported_array.append(card_hand.cards_in_hand[i].export())
		deck_preview.generate_deck(exported_array, reason)
		extra_screens.screens_to_show.push_front(extra_screens.deck_preview_holder)

func play_card(card):
	if game.started and opponent_ready:
		if card_hand.cards_in_hand.size() > 2:
			if card.stats.ability_name == "Tears" and game.last_decision != game.get_player().side:
				return
		
		if set_override_with_card_selection:
			set_override_index(card.index)
		card_to_play = card
		game.get_player().lock()
		
		if card.stats.ability_name == "Categorical Knowledge":
			decision_holder.generate_message("Categorical Knowledge", card)
			extra_screens.screens_to_show.push_front(extra_screens.decision_holder)
		if card.stats.ability_name == "Placeholder":
			generate_deck_preview([card_to_play.index], "Placeholder")
		if card.stats.ability_name == "Extra Space":
			generate_deck_preview([card_to_play.index], "Extra Space")
		
		extra_screens.start_showing_screens()
		if extra_screens.screens_to_show != []:
			await extra_screens.finished
		
		var card_export = card.export()
		
		turn_history["First Used Card"] = [card_export["Attack"], card_export["Defense"]]
		activate_locked_text.rpc(card_export)

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
		#print(game.manager.connected_peer_ids)
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
	print('receiving card!')
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
	if attacking_card["Ability"] == "Dazed and Confused":
		swap_defending = true
	if defending_card["Ability"] == "Dazed and Confused":
		swap_attacking = true
	
	if !has_shuffled:
		if swap_attacking:
			if defending_card["Player ID"] == game.get_player().name:
				print('special shuffle')
				send_card.rpc(true)
				has_shuffled = true
				return
			else:
				attacking_card = card_hand.return_random_card(attacking_card["Index"])
				has_shuffled = true
		if swap_defending:
			#If attacking card is being played by the host
			if attacking_card["Player ID"] == game.get_player().name:
				print('special shuffle')
				send_card.rpc(true)
				has_shuffled = true
				return
			else:
				defending_card = card_hand.return_random_card(defending_card["Index"])
				has_shuffled = true
	
	#print("ATTACKING CARD: " + attacking_card["Name"])
	#print("DEFENDING CARD: " + defending_card["Name"])
	
	pre_card_effects_per_card(attacking_card, defending_card, attacking_info, defending_info)
	
	pre_card_effects(attacking_card, defending_card, attacking_info, defending_info)
	pre_card_effects(defending_card, attacking_card, defending_info, attacking_info)
	
	apply_next_card_bonus_multiplier(attacking_card, attacking_info["Future"])
	apply_next_card_bonus_multiplier(defending_card, defending_info["Future"])
	
	decision = game.turn_decider.decide_outcome(attacking_card, defending_card, attacking_info, defending_info)
	
	clear_future_events()
	clear_future_events.rpc()
	
	override_index = 0
	set_override_with_card_selection = false
	
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
	
	#print("ATTACKING CARD:")
	#print("ATTACK: " + str(attacking_card["Attack"]))
	#print("DEFENSE: " + str(attacking_card["Defense"]))
	#print("ABILITY: " + str(attacking_card["Ability"]))
	#print("")
	#print("DEFENDING CARD:")
	#print("ATTACK: " + str(defending_card["Attack"]))
	#print("DEFENSE: " + str(defending_card["Defense"]))
	#print("ABILITY: " + str(defending_card["Ability"]))
	
	add_to_log(attacking_card, defending_card, decision)
	if host_attacking:
		card_matchup.start(decision, attacking_card, defending_card)
		card_matchup.start.rpc(decision, defending_card, attacking_card)
	else:
		card_matchup.start(decision, defending_card, attacking_card)
		card_matchup.start.rpc(decision, attacking_card, defending_card)
	
	set_ready(false)
	set_ready.rpc(false)
	
	end_turn(decision)
	end_turn.rpc(decision)


@rpc("authority")
func end_turn(decision:Sides):
	var player = game.get_player()
	var _opponent = game.get_opponent()
	
	game.last_decision = decision
	
	cur_stage = Stages.PRE_TURN
	
	extra_screens.start_showing_screens()
	await extra_screens.finished
	
	cur_stage = Stages.PRE_TURN
	
	if decision != Sides.TIE:
		if decision == player.side:
			if card_to_play.stats.should_remove:
				card_hand.remove_card(card_to_play.index)
			else:
				match card_to_play.stats.ability_name:
					"Catalyst":
						generate_deck_preview([card_to_play.index], "Catalyst")
					"Other Priorities":
						print('wat')
						var bonus_attack = card_to_play.stats.true_attack
						var bonus_defense = card_to_play.stats.true_defense
						card_to_play.stats.clear_bonuses()
						card_to_play.stats.set_penalty_attack(card_to_play.stats.base_attack, "Other Priorities")
						card_to_play.stats.set_penalty_defense(card_to_play.stats.base_defense, "Other Priorities")
						deck_preview.bonuses_to_add = [bonus_attack, bonus_defense]
						generate_deck_preview([card_to_play.index], "Other Priorities")
	
	turn_history["Last Used Card"] = [card_to_play.stats.true_attack, card_to_play.stats.true_defense]
	
	if pixel_timer > 0:
		pixel_timer -= 1
		if pixel_timer == 0:
			game.pixel_size = 1
	
	has_shuffled = false
	
	turn_ended.emit()
	on_turn_ended.rpc(card_hand.cards_in_hand.size())
	
	game.get_player().cards_left = card_hand.cards_in_hand.size()
	
	set_ready_call.rpc(opponent_ready)
	locked_text.set_status("WAITING ON OPPONENT")


@rpc("any_peer")
func start_turn():
	#print('STARTING TURN FOR ' + game.get_player().player_name)
	var player = game.get_player()
	var _opponent = game.get_opponent()
	
	locked_text.text = ""
	
	player.switch_side()
	_opponent.switch_side()
	player.unlock()
	_opponent.unlock()
	
	starting_card_effects()
	turn_started.emit()
	cur_stage = Stages.TURN
	
	game.turn_count += 1
	
	
	if game.glitch_timer > 0:
		game.glitch_timer -= 1
		if game.glitch_timer <= 0:
			game.get_node("Glitch").visible = false
	
	#if player.cards_in_hand.size == 1 or opponent.cards_in_hand.size == 1:
	#	print('Game is over!')
	#card_to_play = null

@rpc("any_peer")
func on_turn_ended(cards_left):
	game.get_opponent().cards_left = cards_left

func _on_card_removed():
	for card in card_hand.cards_in_hand:
		if card.stats.ability_name == "Post-Mortem":
			card.stats.add_bonus_attack(1, "Post-Mortem")
			card.stats.add_bonus_defense(1, "Post-Mortem")

func starting_game_card_effects():
	for card in card_hand.cards_in_hand:
		if !card.ability_used:
			match card.stats.ability_name:
				"Paranoia":
					if randi_range(1, 4) == 1:
						card.stats.add_bonus_attack(randi_range(5, 9), "Paranoia")
					else:
						card.stats.add_bonus_attack(randi_range(0, 4), "Paranoia")
					
					if randi_range(1, 4) == 1:
						card.stats.add_bonus_defense(randi_range(5, 9), "Paranoia")
					else:
						card.stats.add_bonus_defense(randi_range(0, 4), "Paranoia")
				"Enthusiast":
					var hyena_upgrades:int = Saves.battle_stats["Hyena Upgrades"]
					var hyena_attack:int = ceil(float(hyena_upgrades) / 2)
					var hyena_defense:int = floor(float(hyena_upgrades) / 2)
					card.stats.base_attack = hyena_attack
					card.stats.bae_defense = hyena_defense
				"Worker's Revolution":
					if Saves.battle_quiz["Employment"]:
						card.stats.add_bonus_attack(2, "Employment")
						card.stats.add_bonus_defense(2, "Employment")
				"Debt":
					var years_attended = Saves.battle_quiz["College Years"]
					if years_attended > 0:
						card.add_penalty_attack(years_attended, "Debt")
					else:
						card.add_bonus_attack(2, "Debt")
				"Speedrun":
					if Saves.battle_quiz["Speedrun"]:
						card.stats.add_bonus_attack(2, "Speedrun")
						card.stats.add_bonus_defense(2, "Speedrun")
				"Leaderboard":
					var composty_attack = ceil(float(Saves.items["Composty Tokens"]) / 2)
					var composty_defense = floor(float(Saves.items["Composty Tokens"]) / 2)
					card.stats.add_bonus_attack(composty_attack, "Leaderboard")
					card.stats.add_bonus_defense(composty_defense, "Leaderboard")
				"The Grind":
					var login_attack = ceil(float(Saves.playerInfo["Login Streak"]) / 2)
					var login_defense = floor(float(Saves.playerInfo["Login Streak"]) / 2)
					
					login_attack = clamp(login_attack, 0, 3)
					login_defense = clamp(login_defense, 0, 3)
					
					card.stats.add_bonus_attack(login_attack, "The Grind")
					card.stats.add_bonus_defense(login_defense, "The Grind")
				"Hosting":
					if game.manager.game_type == game.manager.SERVER:
						card.stats.add_bonus_attack(2, "Hosting")
						card.stats.add_bonus_defense(2, "Hosting")

#For cards thats abilities start at the beginning of a turn
func starting_card_effects():
	time_turn = true
	for card in card_hand.cards_in_hand:
		if card.fire:
			if randi_range(1, 4) == 1:
				card_hand.remove_card(card.index)
		
		if !card.ability_used:
			match card.stats.ability_name:
				"Price Goes Up Yearly":
					if game.get_player().side == Sides.ATTACKING:
						card.stats.add_bonus_attack(1, "Price Goes Up Yearly")
						card.stats.add_bonus_defense(1, "Price Goes Up Yearly")
				"No Show":
					var random = randi_range(0, 20)
					if random == 7:
						card_hand.remove_card(card.index)
				"Deadline":
					if game.get_opponent().cards_left == 2:
						card.add_bonus_attack(2, "Deadline")
					card.ability_check()
				"What Day Is It?":
					if Time.get_date_dict_from_system()["weekday"] == Time.Weekday.WEEKDAY_WEDNESDAY and card.stats.bonuses["What Day Is It?"] == [0, 0]:
						card.stats.set_bonus_attack(1, "What Day Is It?")
						card.stats.set_bonus_defense(1, "What Day Is It?")
				"Editing":
					global.update_save_file_time()
					if card.stats.bonuses["Editing"] == [0, 0] and Saves.playerInfo["Time"] >= 5 * 60 * 60:
						card.stats.add_bonus_attack(2, "Editing")
				"Transform":
					card.stats.bonuses["Transform"] = [0, 0]
					card.stats.set_bonus_attack(turn_history["Last Used Card"][0], "Transform")
					card.stats.set_bonus_defense(turn_history["Last Used Card"][1], "Transform")
				"Grazing":
					if card.stats.bonuses["Grazing"] != [0, 0]:
						card.stats.set_bonus_attack(0, "Grazing")
						card.stats.set_bonus_defense(0, "Grazing")
					if Time.get_time_dict_from_system()["hour"] >= 12 and Time.get_time_dict_from_system()["hour"] < 16:
						card.stats.set_bonus_attack(2, "Grazing")
						card.stats.set_bonus_defense(2, "Grazing")
					else:
						card.stats.set_bonus_attack(0, "Grazing")
						card.stats.set_bonus_defense(0, "Grazing")
				"Electromagnetic Hypersensitivity":
					if card.stats.bonuses["Chincanery"] != [0, 0]:
						card.stats.set_bonus_attack(0, "Chicanery")
						card.stats.set_bonus_defense(0, "Chicanery")
					if Time.get_time_dict_from_system()["hour"] >= 21 and Time.get_time_dict_from_system()["hour"] < 5:
						card.stats.set_bonus_attack(2, "Chicanery")
						card.stats.set_bonus_defense(2, "Chicanery")
				"The Answer":
					if card.stats.bonuses["The Answer"] != [0, 0]:
						card.stats.set_bonus_attack(0, "The Answer")
						card.stats.set_bonus_defense(0, "The Answer")
					for leCard in card_hand.cards_in_hand:
						if leCard.stats.card_name == "Chuck McGill":
							card.stats.add_bonus_attack(2, "The Answer")
							card.stats.add_bonus_defense(2, "The Answer")
				"Ambush Predator":
					if game.turn_count == 1:
						if card.stats.bonuses["Ambush Predator"] == [0, 0]:
							card.stats.set_bonus_attack(2, "Ambush Predator")
							card.stats.set_bonus_defense(2, "Ambush Predator")
					else:
						card.stats.set_bonus_attack(0, "Ambush Predator")
						card.stats.set_bonus_defense(0, "Ambush Predator")
				"Truest Nemo":
					if card_to_play != null:
						if card_to_play.stats.card_series == "Luna":
							card.stats.set_bonus_attack(2, "Truest Nemo")
							card.stats.set_bonus_defense(2, "Truest Nemo")
				"Sensitive":
					if game.last_decision == game.get_player().side:
						card.stats.add_bonus_attack(2, "Sensitive")
						card.stats.add_bonus_defense(2, "Sensitive")
				"Tag-Out":
					var turn_count = game.turn_count - 1
					
					#5-1
					if turn_count % 4 == 0 or turn_count % 4 == 1:
						card.stats.base_attack = 5
						card.stats.base_defense = 1
					#2-3
					if turn_count % 4 == 2 or turn_count % 4 == 3:
						card.stats.base_attack = 2
						card.stats.base_defense = 3
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
				"Molten":
					for i in range(2):
						var random = randi_range(1, 20) 
						if random == 1 or random == 2 or random == 3:
							if i == 0:
								if card_hand.card_exists(card_to_play - 1):
									card_hand.get_card_from_index(card_to_play - 1).fire = true
							elif i == 1:
								if card_hand.card_exists(card_to_play + 1):
									card_hand.get_card_from_index(card_to_play + 1).fire = true
				"Deception":
					if card_hand.cards_in_hand.size() < 3:
						card.stats.card_name = "Pocket Watch"
						card.stats.base_attack = 5
						card.stats.base_defense = 5
					else:
						card.stats.card_name = "Shark Meter"
						card.stats.base_attack = 3
						card.stats.base_defense = 3
				"Fangirl":
					for leCard in card_hand.cards_in_hand:
						if leCard.stats.card_number == "135":
							if card.stats.bonuses["Fangirl"] == [0, 0]:
								card.stats.add_bonus_attack(2, "Fangirl")
								card.stats.add_bonus_defense(2, "Fangirl")
				

# Called before a turn is decided. 
# This will only be called on the host, so can't do anything really permanent
# Save permanent effects for post card effects, use this to create a temporary-
# Version with the exported card
func pre_card_effects(card, affecting_card, info, affecting_info):
	# Don't use the normal match for this, as setting this earlier allows for the normal match to work for this card. 
	if card["Ability"] == "The Goop":
		card["Ability"] = affecting_card["Ability"]
		card["Ability Description"] = affecting_card["Ability Description"]
		card["Should Remove"] = affecting_card["Should Remove"]
		card["One Use Ability"] = affecting_card["One Use Ability"]
	
	if !card["Ability Used"]:
		match card["Ability"]:
			"Neuralyzer":
				affecting_card["Attack"] = affecting_card["Base Attack"]
				affecting_card["Defense"] = affecting_card["Base Defense"]
				
				affecting_card["Bonus Attack"] = 0
				affecting_card["Bonus Defense"] = 0
				ability_check.rpc(card["Index"])
			"Unfunny Tag":
				affecting_card["Attack"] -= 1
				affecting_card["Defense"] -= 1
				
				affecting_card["Penalty Attack"] += 1
				affecting_card["Penalty Defense"] += 1
				
				affecting_card["Penalties"]["Unfunny Tag"] = [1, 1]
				#ability_check.rpc(card["Index"])
			"Simping":
				if affecting_card["Series"] == "Dapper":
					affecting_card["Attack"] -= 2
					affecting_card["Defense"] -= 2
					
					affecting_card["Penalty Attack"] += 2
					affecting_card["Penalty Defense"] += 2
				
					affecting_card["Penalties"]["Simping"] = [2, 2]
			"Walk":
				print(turn_timer)
				if turn_timer <= 30:
					card["Defense"] += 2
					
					card["Bonus Defense"] += 2
				
					card["Bonuses"]["Walk"] = [2, 2]
			"Take Batteries":
				card["Defense"] += 1
				card["Bonus Defense"] += 1
				card["Bonuses"]["Take Batteries"][1] += 1
				
				affecting_card["Attack"] -= 1
				affecting_card["Penalty Attack"] += 1
				card["Penalties"]["Take Batteries"][1] += 1
			"Brainrot":
				affecting_card["Attack"] -= 1
				affecting_card["Defense"] -= 1
				
				affecting_card["Penalty Attack"] += 1
				affecting_card["Penalty Defense"] += 1
				
				affecting_card["Penalties"]["Brainrot"][0] += 1
				affecting_card["Penalties"]["Brainrot"][1] += 1
			"Angry and Senile":
				if affecting_info["Quiz"]["Age"] < 18:
					if card["Bonuses"]["Minors DNI"] == [0, 0]:
						card["Attack"] += 3
						card["Bonus Attack"] += 3
						card["Bonuses"]["Minors DNI"][0] += 3
						
						card["Defense"] -= 1
						card["Penalty Defense"] += 1
						card["Penalties"]["Minors DNI"][1] += 1
			"Last Live: 3 Months Ago":
				if affecting_info["Quiz"]["Twitch"]:
					if card["Peanlties"]["Last Live: 3 Months Ago"] == [0, 0]:
						card["Attack"] -= 2
						card["Penalty Attack"] += 2
						card["Penalties"]["Last Live: 3 Months Ago"][0] += 2
			"Effort Tag":
				if affecting_info["Quiz"]["Object Show"]:
					if card["Peanlties"]["Effort Tag"] == [0, 0]:
						card["Attack"] -= 1
						card["Penalty Attack"] += 1
						card["Penalties"]["Effort Tag"][0] += 1
						
						card["Defense"] -= 1
						card["Penalty Defense"] += 1
						card["Penalties"]["Effort Tag"][1] += 1
			"Awareness":
				if affecting_info["Quiz"]["Server Member"] == "Wibr" or affecting_info["Quiz"]["Server Member"] == "SJ" or affecting_info["Quiz"]["Server Member"] == "Cleft" or affecting_info["Quiz"]["Server Member"] == "Luna" or affecting_info["Quiz"]["Server Member"] == "Cost":
					if card["Bonuses"]["Awareness"] == [0, 0]:
						card["Attack"] += 2
						card["Bonus Attack"] += 2
						card["Penalties"]["Effort Tag"][0] += 2
			"Top 100":
				if info["Quiz"]["Subscribers"] > affecting_info["Quiz"]["Subscribers"]:
					if card["Bonuses"]["Top 100"] == [0, 0]:
						card["Attack"] += 2
						card["Bonus Attack"] += 2
						card["Bonuses"]["Top 100"][0] += 2
						
						card["Defense"] += 2
						card["Bonus Defense"] += 2
						card["Bonuses"]["Top 100"][1] += 2
			"Spreadsheet":
				var average = float(info["Stats"]["Wins"]) / float(info["Stats"]["Losses"])
				var affecting_average = float(affecting_info["Stats"]["Wins"]) / float(affecting_info["Stats"]["Losses"])
				if average > affecting_average:
					card["Attack"] += 2
					card["Bonus Attack"] += 2
					card["Bonuses"]["Spreadsheet"][0] += 2
			"Double It And Pass It To The Next Person":
				card["Attack"] -= card["Bonus Attack"]
				card["Defense"] -= card["Bonus Defense"]
				card["Bonus Attack"] = 0
				card["Bonus Defense"] = 0
				for key in card["Bonuses"].keys():
					card["Bonuses"][key] = [0, 0]
				for key in card["Penalties"].keys():
					card["Penalties"][key] = [0, 0]
			"Three Handed":
				if randi_range(1, 2) == 1:
					card["Attack"] += 2
					card["Bonus Attack"] += 2
					card["Bonuses"]["Three Handed"][0] += 2
				else:
					card["Defense"] += 2
					card["Bonus Defense"] += 2
					card["Bonuses"]["Three Handed"][1] += 2
			"Dance":
				if affecting_info["Info"]["Victory Chest"] > info["Info"]["Victory Chest"]:
					card["Attack"] += 2
					card["Bonus Attack"] += 2
					card["Bonuses"]["Dance"][0] += 2
					
					card["Defense"] += 2
					card["Bonus Defense"] += 2
					card["Bonuses"]["Dance"][1] += 2
# Not the best way to do this, but it stops the code being jumbled in the function already.
# Similar to pre card effects, except not called twice
func pre_card_effects_per_card(attacking_card, defending_card, attacking_info, defending_info):
	apply_next_card_bonus(attacking_card, attacking_info["Future"])
	apply_next_card_bonus(defending_card, defending_info["Future"])
	
	#You gotta add the code for the abilities TWICE!!!!!!
	match attacking_card["Ability"]:
		"Wrong Terminal":
			var attacking_attack = attacking_card["Attack"]
			var attacking_defense = attacking_card["Defense"]
			var attacking_base_attack = attacking_card["Base Attack"]
			var attacking_base_defense = attacking_card["Base Defense"]
			var attacking_bonus_attack = attacking_card["Bonus Attack"]
			var attacking_bonus_defense = attacking_card["Bonus Defense"]
			var attacking_penalty_attack = attacking_card["Penalty Attack"]
			var attacking_penalty_defense = attacking_card["Penalty Defense"]
			var attacking_bonuses = attacking_card["Bonuses"]
			var attacking_penalties = attacking_card["Penalties"]
			
			attacking_card["Attack"] = defending_card["Attack"]
			attacking_card["Defense"] = defending_card["Defense"]
			attacking_card["Base Attack"] = defending_card["Base Attack"]
			attacking_card["Base Defense"] = defending_card["Base Defense"]
			attacking_card["Bonus Attack"] = defending_card["Bonus Attack"]
			attacking_card["Bonus Defense"] = defending_card["Bonus Defense"]
			attacking_card["Penalty Attack"] = defending_card["Penalty Attack"]
			attacking_card["Penalty Defense"] = defending_card["Penalty Defense"]
			attacking_card["Penalties"] = defending_card["Penalties"]
			attacking_card["Bonueses"] = defending_card["Bonuses"]
			
			defending_card["Attack"] = attacking_attack
			defending_card["Defense"] = attacking_defense
			defending_card["Base Attack"] = attacking_base_attack
			defending_card["Base Defense"] = attacking_base_defense
			defending_card["Bonus Attack"] = attacking_bonus_attack
			defending_card["Bonus Defense"] = attacking_bonus_defense
			defending_card["Penalty Attack"] = attacking_penalty_attack
			defending_card["Penalty Defense"] = attacking_penalty_defense
			defending_card["Penalties"] = attacking_penalties
			defending_card["Bonueses"] = attacking_bonuses
	
	match defending_card["Ability"]:
		"Wrong Terminal":
			var defending_attack = defending_card["Attack"]
			var defending_defense = defending_card["Defense"]
			var defending_base_attack = defending_card["Base Attack"]
			var defending_base_defense = defending_card["Base Defense"]
			var defending_bonus_attack = defending_card["Bonus Attack"]
			var defending_bonus_defense = defending_card["Bonus Defense"]
			var defending_penalty_attack = defending_card["Penalty Attack"]
			var defending_penalty_defense = defending_card["Penalty Defense"]
			var defending_bonuses = defending_card["Bonuses"]
			var defending_penalties = defending_card["Penalties"]
			
			defending_card["Attack"] = attacking_card["Attack"]
			defending_card["Defense"] = attacking_card["Defense"]
			defending_card["Base Attack"] = attacking_card["Base Attack"]
			defending_card["Base Defense"] = attacking_card["Base Defense"]
			defending_card["Bonus Attack"] = attacking_card["Bonus Attack"]
			defending_card["Bonus Defense"] = attacking_card["Bonus Defense"]
			defending_card["Penalty Attack"] = attacking_card["Penalty Attack"]
			defending_card["Penalty Defense"] = attacking_card["Penalty Defense"]
			defending_card["Penalties"] = attacking_card["Penalties"]
			defending_card["Bonueses"] = attacking_card["Bonuses"]
			
			attacking_card["Attack"] = defending_attack
			attacking_card["Defense"] = defending_defense
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
	if card_to_play.stats.ability_name == "The Goop":
		card_to_play.stats.ability_name = opposing_card["Ability"]
		card_to_play.stats.ability_description = opposing_card["Ability Description"]
		card_to_play.stats.should_remove = opposing_card["Should Remove"]
		card_to_play.stats.one_use_ability = opposing_card["One Use Ability"]
	
	#print(card_to_play.stats.ability_name)
	# Abilities that affect the OPPOSING player
	if !opposing_card["Ability Used"]:
		match opposing_card["Ability"]:
			"Neuralyzer":
				for card in card_hand.cards_in_hand:
					card.stats.clear_bonuses()
			"Owner Perms":
				if decision == opposing_card["Side"]:
					card_hand.disable_card(card_to_play.index, 2)
			"Strategist":
				var random_card = card_hand.cards_in_hand[randi_range(0, card_hand.cards_in_hand.size() - 1)]
				card_preview.generate_preview_from_export.rpc(random_card.export())
				extra_screens.screens_to_show.push_front(extra_screens.card_preview_holder)
			"Kindness":
				if decision == opposing_card["Side"]:
					#print('should be working?')
					card_to_play.stats.add_bonus_attack(2, "Kindness")
					card_to_play.stats.add_bonus_defense(2, "Kindness")
			"Torrenting":
				if decision == game.get_player().side:
					var index = randi_range(0, card_hand.cards_in_hand.size() - 1)
					while index == card_to_play.index:
						index = randi_range(0, card_hand.cards_in_hand.size() - 1)
					
					# NEEDS STATUS MESSAGE
					
					card_hand.add_card.rpc(card_hand.get_card_from_index(index).export())
					card_hand.remove_card(index)
			"Clean Timeline":
				if decision == opposing_card["Side"]:
					for i in range(int(card_hand.cards_in_hand.size() / 2)):
						var index:int = randi_range(0, card_hand.cards_in_hand.size() - 1)
						while card_hand.get_card_from_index(index).disabled == true:
							index = randi_range(0, card_hand.cards_in_hand.size() - 1)
						card_hand.disable_card(index, 2)
			"Acidic":
				if decision == opposing_card["Side"]:
					for card in card_hand.cards_in_hand:
						card.stats.add_penalty_defense(1, "Acidic")
			"SO RETRO!":
				set_pixel_effect(7, 4)
			"Haunt":
				if decision == game.get_player().side:
					future_events["Haunt"] = [FutureEvents.NEXT_CARD_PENALTY, [2, 0]]
					print("WHY: " + str(future_events["Haunt"]))
			"Strike":
				if randi_range(1, 4) == 1:
					var exception = randi_range(0, card_hand.cards_in_hand.size() - 1)
					while exception == card_to_play.index:
						exception = randi_range(0, card_hand.cards_in_hand.size() - 1)
					print('EXCEPTION: ' + str(exception))
					for i in range(card_hand.cards_in_hand.size()):
						if i != exception:
							card_hand.disable_card(i, 2)
			"Dead Server":
				card_to_play.stats.ability_name = ""
				card_to_play.stats.ability_description = ""
				card_to_play.stats.one_use_ability = false
				card_to_play.stats.should_remove = true
				card_to_play.stats.hide_stats = false
			"Scrap":
				paper.generate_crumple()
			"Untrustworthiness":
				locked_text.show_ability = false
				locked_text.show_stats = false
				locked_text.ability_timer = 0
				locked_text.stats_timer = 0
			"Take Batteries":
				card_to_play.stats.add_penalty_attack(1, "Take Batteries")
			"Distracted":
				#NEEDS STATUS
				if decision == opposing_card["Side"]:
					for card in card_hand.cards_in_hand:
						card.stats.ability_description = ""
				ability_check.rpc(opposing_card["Index"])
			".":
				opposing_card["Ability Used"] = true
				card_hand.add_card(opposing_card)
			"Insults":
				if decision == opposing_card["Side"]:
					card_to_play.add_penalty_attack(2, "Insults")
					card_to_play.add_penalty_defense(2, "Insults")
			"Thief":
				if decision == opposing_card["Side"]:
					card_hand.replace_card(card_to_play.index, "-1", false)
			"Null Reference":
				game.get_node("Glitch").visible = true
				game.glitch_timer = 3
			"Foliage":
				var ability_packed_array = []
				for card in card_hand.cards_in_hand:
					ability_packed_array.append([card.stats.ability_name, card.stats.ability_description, card.stats.one_use_ability, card.stats.should_remove, card.hide_stats])
				ability_packed_array.shuffle()
				for i in card_hand.cards_in_hand.size():
					card_hand.cards_in_hand[i].stats.ability_name = ability_packed_array[i][0]
					card_hand.cards_in_hand[i].stats.ability_description = ability_packed_array[i][1]
					card_hand.cards_in_hand[i].stats.one_use_ability = ability_packed_array[i][2]
					card_hand.cards_in_hand[i].stats.should_remove = ability_packed_array[i][3]
					card_hand.cards_in_hand[i].stats.hide_stats = ability_packed_array[i][4]
				ability_check.rpc(opposing_card["Index"])
			"Telekenesis":
				mouse_control.enabled = true
				mouse_control.enabled_timer = 3
	
	
	#Abilities that affect the PLAYER
	if !card_to_play.ability_used:
		match card_to_play.stats.ability_name:
			"The 1K Race":
				if decision == opposing_card["Side"] and card_hand.removed_cards.size() > 0:
					card_hand.readd_card(randi_range(0, card_hand.removed_cards.size() - 1))
			"Boost":
				for card in card_hand.cards_in_hand:
					if card != card_to_play:
						card.stats.add_bonus_defense(1, "Boost")
				card_to_play.ability_check()
			"Gamer Rage":
				if decision == opposing_card["Side"]:
					card_to_play.stats.add_bonus_attack(2, "Gamer Rage")
					card_to_play.ability_check()
			"Radio Broadcast":
				locked_text.show_stats = true
				locked_text.stats_timer = 4
			"Pass It On":
				if decision == opposing_card["Side"]:
					future_events["Pass It On"] = [FutureEvents.NEXT_CARD_BONUS, [floor(float(card_to_play.stats.true_attack) / 2), floor(float(card_to_play.stats.true_defense) / 2)]]
			"Cash Out":
				print('crypto activated?')
				for card in card_hand.cards_in_hand:
					if card.stats.true_attack <= 3:
						card.stats.add_bonus_attack(2, "Cash Out")
					if card.stats.true_defense <= 3:
						card.stats.add_bonus_defense(2, "Cash Out")
				card_to_play.ability_check()
			"Torrenting":
				if decision == opposing_card["Side"]:
					# NEEDS STATUS MESSAGE
					card_hand.add_card.rpc(card_to_play.export())
					card_hand.remove_card(card_to_play.index)
			"All Powerful":
				card_to_play.stats.add_penalty_attack(1, "All Powerful")
				card_to_play.stats.add_penalty_defense(1, "All Powerful")
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
			"Nectar of the Gods":
				for card in card_hand.cards_in_hand:
					if randi_range(0, 1) == 0:
						card.stats.add_bonus_attack(1, "Nectar of the Gods")
					else:
						card.stats.add_bonus_defense(1, "Nectar of the Gods")
				card_to_play.ability_check()
			"Kromer":
				kromer = true
			"Wrong Terminal":
				card_to_play.stats.bonuses = opposing_card["Bonuses"]
				card_to_play.stats.penalties = opposing_card["Penalties"]
				card_to_play.stats.base_attack = opposing_card["Base Attack"]
				card_to_play.stats.base_defense = opposing_card["Base Defense"]
				card_to_play.stats.can_get_bonuses = opposing_card["Can Get Bonuses"]
				ability_check(card_to_play.index)
			"Good Morning":
				future_events["Good Morning"] = [FutureEvents.NEXT_CARD_BONUS, [0, 3]]
			"Take Batteries":
				card_to_play.stats.add_bonus_defense(1, "Take Batteries")
			"Angry and Senile":
				if opposing_info["Quiz"]["Age"] < 18:
					card_to_play.stats.add_bonus_attack(3, "Angry and Senile")
					card_to_play.stats.add_penalty_defense(1, "Angry and Senile")
					card_to_play.ability_check()
			"Fruitless Passion":
				if Saves.battle_quiz["Projects"]:
					future_events["Fruitless Passion"] = [FutureEvents.NEXT_CARD_BONUS, [1, 1]]
			"Effort Tag":
				if opposing_info["Quiz"]["Object Show"]:
					if card_to_play.stats.penalties["Effort Tag"] == [0, 0]:
						card_to_play.stats.add_penalty_attack(1, "Effort Tag")
						card_to_play.stats.add_penalty_defense(1, "Effort Tag")
						card_to_play.ability_check()
			"Awareness":
				if opposing_info["Quiz"]["Server Member"] == "Wibr" or opposing_info["Quiz"]["Server Member"] == "SJ" or opposing_info["Quiz"]["Server Member"] == "Cleft" or opposing_info["Quiz"]["Server Member"] == "Luna" or opposing_info["Quiz"]["Server Member"] == "Cost":
					if card_to_play.stats.bonuses["Awareness"] == [0, 0]:
						card_to_play.stats.add_bonus_attack(2, "Awareness")
						card_to_play.ability_check()
			"Top 100":
				if Saves.battle_quiz["Subscribers"] > opposing_info["Quiz"]["Subscribers"]:
					if card_to_play.bonuses["Top 100"] == [0, 0]:
						card_to_play.stats.add_bonus_attack(2, "Top 100")
						card_to_play.stats.add_bonus_defense(2, "Top 100")
						card_to_play.ability_check()
			'Office GIF':
				future_events["Office GIF"] = [FutureEvents.NEXT_CARD_BONUS_MULTIPLIER, [2, 2]]
				card_to_play.ability_check()
			"Charity":
				for card in card_hand.cards_in_hand:
					if card != card_to_play:
						card.add_bonus_attack(card_to_play.stats.get_bonus_attack(), "Charity")
						card.add_bonus_defense(card_to_play.stats.get_bonus_defense(), "Charity")
				card_to_play.ability_check()
			"Double It And Pass It To The Next Person":
				future_events["Double It And Pass It To The Next Person"] = [FutureEvents.NEXT_CARD_BONUS, [card_to_play.stats.get_bonus_attack(), card_to_play.stats.get_bonus_defense()]]
				for key in card_to_play.stats.bonuses.keys():
					card_to_play.stats.set_bonus_attack(0, key)
					card_to_play.stats.set_bonus_defense(0, key)
				for key in card_to_play.stats.penalties.keys():
					card_to_play.stats.set_penalty_attack(0, key)
					card_to_play.stats.set_penalty_defense(0, key)
			"Presidential Pardon":
				for card in card_hand.cards_in_hand:
					if card != card_to_play:
						for penalty in card.stats.penalties:
							if card.stats.penalties[penalty][0] > 1:
								card.stats.add_penalty_attack(-1, penalty)
							if card.stats.penalties[penalty][1] > 1:
								card.stats.add_penalty_defense(-1, penalty)
				card_to_play.ability_check()
			"Voltage":
				if decision == opposing_card["Side"]:
					var half_of_deck:int = floor(float(card_hand.cards_in_hand.size()) / 2)
					var indexes_to_disable = []
					for i in range(half_of_deck):
						var index = randi_range(0, card_hand.cards_in_hand.size() - 1)
						for leIndex in indexes_to_disable:
							while index == leIndex:
								index = randi_range(0, card_hand.cards_in_hand.size() - 1)
						indexes_to_disable.append(index)
			"Deceiver":
				set_override_with_card_selection = true
	
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_LOSS_BONUS and decision == opposing_card["Side"] and future_events[key][1] != [0, 0]:
			card_to_play.stats.add_bonus_attack(future_events[key][1][0], key)
			card_to_play.stats.add_bonus_defense(future_events[key][1][1], key)
			future_events[key][1] = [0, 0]
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_LOSS_PENALTY and decision == opposing_card["Side"] and future_events[key][1] != [0, 0]:
			card_to_play.stats.add_penalty_attack(future_events[key][1][0], key)
			card_to_play.stats.add_penalty_defense(future_events[key][1][1], key)
			future_events[key][1] = [0, 0]
	if opposing_card["Ability"] == "Curse":
		geometry.start()
		geometry.answered.connect(
			func (correct):
				if !correct:
					var rand1 = randi_range(0, card_hand.cards_in_hand.size() - 1)
					while rand1 == card_to_play.index:
						rand1 = randi_range(0, card_hand.cards_in_hand.size() - 1)
					var rand2 = randi_range(0, card_hand.cards_in_hand.size() - 1)
					while rand2 == rand1 or rand2 == card_to_play.index:
						rand2 = randi_range(0, card_hand.cards_in_hand.size() - 1)
					var rand3 = randi_range(0, card_hand.cards_in_hand.size() - 1)
					while rand3 == rand1 or rand3 == rand2 or rand1 == card_to_play.index:
						rand3 = randi_range(0, card_hand.cards_in_hand.size() - 1)
					card_hand.disable_card(rand1)
					card_hand.disable_card(rand2)
					card_hand.disable_card(rand3)
		)
		ability_check.rpc(opposing_card["Index"])
		extra_screens.screens_to_show.push_front(extra_screens.geometry)
		await(geometry.hidden)
#Called at the end of every turn for EVERY card in your hand. 
@rpc("authority")
func passive_card_abilities(_opposing_card, decision):
	for card in card_hand.cards_in_hand:
		match card.stats.ability_name:
			"Revenge Shot":
				if decision != game.get_player().side and decision != Sides.TIE:
					if card.stats.bonuses["Revenge Shot"] == [0, 0]:
						#print("Revenge Shot (SJ) Activated!")
						card.stats.add_bonus_attack((card.stats.true_attack * 2) - card.stats.base_attack, "Revenge Shot")
						card.stats.add_bonus_defense((card.stats.true_defense * 2)  - card.stats.base_defense, "Revenge Shot")
				else:
					card.stats.set_bonus_attack(0, "Revenge Shot")
					card.stats.set_bonus_defense(0, "Revenge Shot")
			"Up and Coming":
				if decision == game.get_player().side:
					card.stats.add_bonus_attack(1, "Up and Coming")
					card.stats.add_bonus_defense(1, "Up and Coming")
				elif decision == game.get_opponent().side:
					card.stats.set_bonus_attack(0, "Up and Coming")
					card.stats.set_bonus_defense(0, "Up and Coming")
			"Speeding":
				if decision == game.get_player().side:
					if card.favor == false:
						card.stats.add_bonus_attack(1, "Speeding")
						card.stats.add_penalty_defense(1, "Speeding")
					else:
						card.stats.add_bonus_defense(1, "Speeding")
						card.stats.add_penalty_attack(1, "Speeding")
			"Rising":
				card.stats.set_bonus_attack(0, "Rising")
				card.stats.set_bonus_defense(0, "Rising")
				
				card.stats.add_bonus_attack(card.stats.get_bonus_attack(), "Rising")
				card.stats.add_bonus_defense(card.stats.get_bonus_defense(), "Rising")
			"First Used Card":
				card.stats.set_bonus_attack(turn_history["First Used Card"][0], "First Used Card")
				card.stats.set_bonus_defense(turn_history["First Used Card"][1], "First Used Card")
			"Bathroom Break":
				for message in $chatbox.text_box.get_children():
					if message.sender == game.get_opponent().player_name:
						if card.stats.penalties["Bathroom Break"] == [0, 0]:
							card.stats.set_penalty_attack(1, "Bathroom Break")
							card.stats.set_penalty_defense(1, "Bathroom Break")

@rpc("authority")
func clear_future_events():
	#Clear future events as this will set them?
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_CARD_BONUS or future_events[key][0] == FutureEvents.NEXT_CARD_PENALTY or future_events[key][0] == FutureEvents.NEXT_CARD_BONUS_MULTIPLIER or future_events[key][0] == FutureEvents.NEXT_CARD_PENALTY_MULTIPLIER:
			future_events[key][1] = [0, 0]

func apply_next_card_bonus(card, le_future_events):
	for key in le_future_events.keys():
		if le_future_events[key][0] == FutureEvents.NEXT_CARD_BONUS and le_future_events[key][1] != [0, 0]:
			card["Attack"] += le_future_events[key][1][0]
			card["Defense"] += le_future_events[key][1][1]
			card["Bonus Attack"] += le_future_events[key][1][0]
			card["Bonus Defense"] += le_future_events[key][1][1]
			card["Bonuses"][key] = le_future_events[key][1]
		if le_future_events[key][0] == FutureEvents.NEXT_CARD_PENALTY and le_future_events[key][1] != [0, 0]:
			card["Attack"] -= le_future_events[key][1][0]
			card["Defense"] -= le_future_events[key][1][1]
			card["Penalty Attack"] += le_future_events[key][1][0]
			card["Penalty Defense"] += le_future_events[key][1][1]
			card["Penalties"][key] = le_future_events[key][1]
func apply_next_card_bonus_multiplier(card, le_future_events):
	for key in le_future_events.keys():
		if le_future_events[key][0] == FutureEvents.NEXT_CARD_BONUS_MULTIPLIER and future_events[key][1] != [0, 0]:
			var ability_name = card["Ability"]
			var bonus_amount = card["Bonuses"][ability_name]
			var multiplier = le_future_events[key][1][0]
			
			card["Bonuses"][ability_name][0] *= le_future_events[key][1][0]
			card["Bonuses"][ability_name][1] *= le_future_events[key][1][1]
			card["Attack"] += bonus_amount[0] * multiplier[0]
			card["Defense"] += bonus_amount[1] * multiplier[1]
			card["Bonus Attack"] += bonus_amount[0] * multiplier[0]
			card["Bonus Defense"] += bonus_amount[1] * multiplier[1]

@rpc("any_peer")
func set_override_index(value:int):
	override_index = value

func get_info():
	var dict = {}
	dict["Victory Chest"] = card_hand.victory_chest.get_children().size()
	return dict

@rpc("any_peer")
func add_bonus_attack(index, amount, reason):
	print("Adding bonus attack to " + card_hand.get_card_from_index(index).stats.card_name)
	card_hand.get_card_from_index(index).stats.add_bonus_attack(amount, reason)

@rpc("any_peer")
func add_bonus_defense(index, amount, reason):
	print("Adding bonus defense to " + card_hand.get_card_from_index(index).stats.card_name)
	card_hand.get_card_from_index(index).stats.add_bonus_defense(amount, reason)

@rpc("any_peer")
func set_ready_call(curStatus):
	#print(game.get_opponent().player_name + "IS READY!!")
	opponent_ready = true
	if curStatus == true:
		start_turn()
		start_turn.rpc()
@rpc("any_peer")
func set_ready(val):
	opponent_ready = val

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
