extends Control

signal turn_started
signal turn_ended

#You get the drill by now
enum Sides {
	ATTACKING,
	DEFENDING,
	TIE
}
enum FutureEvents {
	NEXT_CARD,
	NEXT_LOSS
}

@onready var game = get_parent()

@onready var card_hand = $card_hand
@onready var card_preview = $card_preview_holder
@onready var deck_preview = $deck_preview_holder
@onready var locked_text = $locked_text

var cards_to_generate = ["006", "1", "010", "012", "015", "016", "043", "019"]
var card_to_play

var is_in_preview:bool :
	set(value):
		is_in_preview = value
		if is_in_preview:
			%darken.visible = true
		else:
			%darken.visible = false

# Bonuses to add onto the next card played
# Check to see if any of these values are not [FutureEvents._, 0, 0] when played
# Can currently only be used in pre_card_effects
var future_events:Dictionary = {
	"Pass It On" : [[0, 0]],
	"Winter Scavenging" : [[0, 0]]
}
var turn_history:Dictionary = {
	"Reminiscing" : [0, 0]
}

var cash_out:bool = false

func _process(_delta):
	%mouse_detection.global_position = get_global_mouse_position()

func _unhandled_input(_event):
	pass
	#if event.is_action_pressed("hyena"):
	#	generate_deck_preview()

func generate_deck_preview(exclude:Array = [-1], reason:String = ""):
	if !is_in_preview:
		is_in_preview = true
		var exported_array:Array = []
		for i in range(card_hand.cards_in_hand.size()):
			for excluded_i in exclude:
				if i != excluded_i:
					exported_array.append(card_hand.cards_in_hand[i].export())
		deck_preview.generate_deck(exported_array, reason)

func play_card(card):
	card_to_play = card
	game.get_player().lock()
	
	var card_export = card.export()
	
	turn_history["Reminiscing"] = [FutureEvents.NEXT_CARD, [card_export["Attack"], card_export["Defense"]]]
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
func send_card():
	receive_card.rpc_id(1, card_to_play.export(), future_events)

# Receives a card from the opposing player to see if they win/lose
# This is only received by the HOST
@rpc("any_peer")
func receive_card(exported_card, exported_future):
	var attacking_card:Dictionary
	var defending_card:Dictionary
	
	var attacking_future:Dictionary
	var defending_future:Dictionary
	
	var decision:Sides
	if exported_card["Side"] == Sides.ATTACKING:
		attacking_card = exported_card
		defending_card = card_to_play.export()
		attacking_future = exported_future
		defending_future = future_events
	else:
		defending_card = exported_card
		attacking_card = card_to_play.export()
		defending_future = exported_future
		attacking_future = future_events
	
	pre_card_effects(attacking_card, defending_card, attacking_future, defending_future)
	pre_card_effects(defending_card, attacking_card, defending_future, attacking_future)
	
	decision = game.turn_decider.decide_outcome(attacking_card, defending_card)
	
	#Clear future events as this will set them?
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_CARD:
			future_events[key][1] = [0, 0]
	
	post_card_effects.rpc(card_to_play.export(), decision, future_events)
	post_card_effects(exported_card, decision, exported_future)
	
	passive_card_abilities.rpc(card_to_play.export(), decision)
	passive_card_abilities(exported_card, decision)
	
	end_turn(decision)
	end_turn.rpc(decision)


@rpc("authority")
func end_turn(decision:Sides):
	var player = game.get_player()
	var _opponent = game.get_opponent()
	
	if decision != Sides.TIE:
		if decision == player.side:
			if card_to_play.stats.should_remove:
				card_hand.remove_card(card_to_play.index)
			else:
				match card_to_play.stats.ability_name:
					"Catalyst":
						generate_deck_preview([card_to_play.index], "Catalyst")
					"Other Priorities":
						var bonus_attack = card_to_play.stats.true_attack
						var bonus_defense = card_to_play.stats.true_defense
						card_to_play.stats.clear_bonuses()
						card_to_play.stats.set_penalty_attack(card_to_play.stats.base_attack, "Other Priorities")
						card_to_play.stats.set_penalty_defense(card_to_play.stats.base_defense, "Other Priorities")
						deck_preview.bonuses_to_add = [bonus_attack, bonus_defense]
						generate_deck_preview([card_to_play.index], "Other Priorities")
	
	player.switch_side()
	_opponent.switch_side()
	player.unlock()
	_opponent.unlock()
	turn_ended.emit()
	
	on_turn_ended.rpc(card_hand.cards_in_hand.size())
	game.get_player().cards_left = card_hand.cards_in_hand.size()
	
	starting_card_effects()
	turn_started.emit()
	
	game.turn_count += 1
	
	#if player.cards_in_hand.size == 1 or opponent.cards_in_hand.size == 1:
	#	print('Game is over!')
	#card_to_play = null

@rpc("any_peer")
func on_turn_ended(cards_left):
	game.get_opponent().cards_left = cards_left

func _on_card_removed(cards_left):
	for card in card_hand.cards_in_hand:
		if card.stats.ability_name == "Post-Mortem":
			card.add_bonus_attack(1, "Post-Mortem")
			card.add_bonus_defense(1, "Post-Mortem")

#For cards thats abilities start at the beginning of a turn
func starting_card_effects():
	for card in card_hand.cards_in_hand:
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
# Called before a turn is decided. 
# This will only be called on the host, so can't do anything really permanent
# Save permanent effects for post card effects, use this to create a temporary-
# Version with the exported card
func pre_card_effects(card, affecting_card, playing_future_events, affecting_future_events):
	for key in playing_future_events.keys():
		if playing_future_events[key][0] == FutureEvents.NEXT_CARD and playing_future_events[key][1] != [0, 0]:
			card["Attack"] += playing_future_events[key][1][0]
			card["Defense"] += playing_future_events[key][1][1]
			card["Bonus Attack"] += playing_future_events[key][1][0]
			card["Bonus Defense"] += playing_future_events[key][1][1]
	for key in affecting_future_events.keys():
		if affecting_future_events[key][0] == FutureEvents.NEXT_CARD and affecting_future_events[key][1] != [0, 0]:
			affecting_card["Attack"] += affecting_future_events[key[1]][0]
			affecting_card["Defense"] += affecting_future_events[key][1][1]
			affecting_card["Bonus Attack"] += affecting_future_events[key][1][0]
			affecting_card["Bonus Defense"] += affecting_future_events[key][1][1]
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
				#ability_check.rpc(card["Index"])


@rpc("authority")
func post_card_effects(opposing_card, decision, opposing_future_events):
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
					
					card_hand.add_card.rpc(card_hand.get_card_from_index(card_to_play.index))
					card_hand.remove_card(card_to_play.index)
			"Clean Timeline":
				if decision == opposing_card["Side"]:
					for i in range(int(card_hand.cards_in_hand.size() / 2)):
						var index:int = randi_range(0, card_hand.cards_in_hand.size() - 1)
						while card_hand.get_card_from_index(index).disabled == true:
							index = randi_range(0, card_hand.cards_in_hand.size() - 1)
						card_hand.get_card_from_index(index).disable()
			"Acidic":
				if decision == opposing_card["Side"]:
					for card in card_hand.cards_to_play:
						card.stats.add_penalty_defense(1, "Acidic")
	
	
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
				locked_text.stats_timer = 3
			"Pass It On":
				if decision == opposing_card["Side"]:
					future_events["Pass It On"] = [FutureEvents.NEXT_CARD, [floor(float(card_to_play.stats.true_attack) / 2), floor(float(card_to_play.stats.true_defense) / 2)]]
			"The Goop":
				card_to_play.stats.ability_name = opposing_card["Ability"]
				card_to_play.ability_description = opposing_card["Ability Description"]
			"Cash Out":
				cash_out = true
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
				locked_text.ability_timer = 0
			"Winter Scavenging":
				future_events["Winter Scavenging"] = [FutureEvents.NEXT_LOSS, [1, 1]]
			"Fear of God":
				var fate = randi_range(1, 5)
				if fate == 1:
					card_hand.remove_all_cards()
				else:
					card_hand.remove_all_cards.rpc()
			"Nectar of the Gods":
				for card in card_hand.cards_in_hand:
					card.add_bonus_attack(1, "Nectar of the Gods")
					card.add_bonus_defense(1, "Nectar of the Gods")
	
	for key in future_events.keys():
		if future_events[key][0] == FutureEvents.NEXT_LOSS and decision == opposing_card["Side"]:
			card_to_play.add_bonus_attack(future_events[key][0], key)
			card_to_play.add_bonus_defense(future_events[key][0], key)
			future_events[key][1] = [0, 0]

#Called at the end of every turn for EVERY card in your hand. 
@rpc("authority")
func passive_card_abilities(_opposing_card, decision):
	for card in card_hand.cards_in_hand:
		match card.stats.ability_name:
			"Revenge Shot":
				if decision != game.get_player().side and decision != Sides.TIE:
					if card.stats.bonuses["Revenge Shot"] == [0, 0]:
						print("Revenge Shot (SJ) Activated!")
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
				
				card.stats.add_bonus_attack(card.stats.get_bonus_attack() * 2, "Rising")
				card.stats.add_bonus_defense(card.stats.get_bonus_defense() * 2, "Rising")
			"Reminiscing":
				card.stats.set_bonus_attack(future_events["Reminiscing"][0], "Reminiscing")
				card.stats.set_bonus_defense(future_events["Reminiscing"][1], "Reminiscing")
		card.ability_check()
		if cash_out and card.bonuses["Cash Out"] == [0, 0]:
			if card.stats.true_attack <= 3:
				card.stats.add_bonus_attack(2, "Cash Out")
			if card.stats.true_defense <= 3:
				card.stats.add_bonus_defense(2, "Cash Out")

@rpc("any_peer")
func add_bonus_attack(index, amount, reason):
	print("Adding bonus attack to " + card_hand.get_card_from_index(index).stats.card_name)
	card_hand.get_card_from_index(index).stats.add_bonus_attack(amount, reason)

@rpc("any_peer")
func add_bonus_defense(index, amount, reason):
	print("Adding bonus defense to " + card_hand.get_card_from_index(index).stats.card_name)
	card_hand.get_card_from_index(index).stats.add_bonus_defense(amount, reason)

