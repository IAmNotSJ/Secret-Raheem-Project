extends Control

signal card_removed
signal card_added

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

@onready var ui = get_parent()

@onready var victory_chest = %victory_chest


var cards_in_hand = []
var removed_cards = []
var disabled_cards = []

var focused:bool = false

var x_offset:int = 0
var y_offset:int = 0

var cur_seperation:float = -59.55
var victory_seperation:float = -59.55
var victory_position:int = 977

func _ready():
	%DayNightCycle.visible = Saves.battle_settings["DayNight"]

func _process(delta):
	if global.isWindowFocused:
		var distance_from_center:float = (get_global_mouse_position().x - (1280 / 2)) / ((1280 / 2)) * -1
		distance_from_center = clamp(distance_from_center, -1, 1)
		var card_offset = cards_in_hand.size() - 8
		if card_offset < 0:
			card_offset = 0
		if !ui.is_in_preview:
			#%offset.position.x = lerpf(%offset.position.x, (150 * cards_in_hand.size()) * distance_from_center - %held_cards.size.x / 2, 20 * delta)
			if card_offset > 0:
				%offset.position.x = lerpf(%offset.position.x, ((150 * card_offset)) * (distance_from_center), 20 * delta)
			else:
				%offset.position.x = lerpf(%offset.position.x, 0, 20 * delta)
			%offset.position.y = lerpf(%offset.position.y, y_offset , 15 * delta)
		
		cur_seperation = lerpf(cur_seperation, victory_seperation, 10 * delta)
		victory_chest.add_theme_constant_override("separation", cur_seperation)
		victory_chest.position.x = lerpf(victory_chest.position.x, victory_position, 10 * delta)

func generate_cards():
	if ui.game.match_rules == {}:
		await ui.game.match_rules_received
	var cards_to_generate = Saves.battle_deck[ui.game.match_rules["Deck Size"]]
	for i in range(cards_to_generate.size()):
		var card = card_scene.instantiate()
		card.stats = card.return_stats_from_resource("res://minigames/raheem_battle/cards/card_variants/stats/" + cards_to_generate[i] + ".tres")
		card.index = i
		cards_in_hand.append(card)
		card.left_clicked.connect(ui.play_card)
		card.disabled_changed.connect(_on_card_disabled)
		card.right_clicked.connect(ui.card_preview.generate_card_preview)
		ui.turn_ended.connect(card._on_turn_ended)
		%held_cards.add_child(card)
		if cards_in_hand.size() > 8:
			x_offset += card.size.x

@rpc("any_peer")
func add_card(export:Dictionary, wait:bool = false, playable:bool = true):
	if wait:
		await ui.turn_started
	var card = card_scene.instantiate()
	
	card.stats = card.return_stats_from_export(export)
	
	cards_in_hand.append(card)
	card.left_clicked.connect(ui.play_card)
	card.right_clicked.connect(ui.card_preview.generate_card_preview)
	%held_cards.add_child(card)
	
	card.send_card_status("Added!")
	
	for i in range(%held_cards.get_children().size()):
		if card == %held_cards.get_children()[i]:
			card.index = i
	
	if cards_in_hand.size() > 8:
		x_offset += card.size.x
	
	if !playable:
		disable_card(card.index, 100000)
	
	return card

func add_card_from_resource(number:String, forced_index:int = -1):
	var card = card_scene.instantiate()
	var stats_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + number + ".tres"
	var stats = load(stats_path)
	
	card.stats["Card Name"] = stats.card_name
	card.stats["Card Series"] = stats.card_series
	card.stats["Card Number"] = stats.card_number
	card.stats["Base Attack"] = stats.base_attack
	card.stats["Base Defense"] = stats.base_defense
	card.stats["Can Get Bonuses"] = stats.can_get_bonuses
	card.stats["Ability Name"] = stats.ability_name
	card.stats["Ability Description"] = stats.ability_description
	card.stats["One Use Ability"] = stats.one_use_ability
	card.stats["Should Remove"] = stats.should_remove
	card.stats["Hide Stats"] = stats.hide_stats
	card.stats["Is Human"] = stats.is_human
	card.stats["Has Hands"] = stats.has_hands
	
	cards_in_hand.append(card)
	card.left_clicked.connect(ui.play_card)
	card.right_clicked.connect(ui.card_preview.generate_card_preview)
	ui.turn_ended.connect(card._on_turn_ended)
	%held_cards.add_child(card)
	if forced_index == -1:
		card.index = cards_in_hand.size() - 1
	else:
		%held_cards.move_child(card, forced_index)
	reindex_deck()
	if cards_in_hand.size() > 8:
		x_offset += card.size.x
	
	return card

@rpc("any_peer")
func remove_card(index, put_in_victory_chest:bool = true, reindex:bool = true, wait:bool = true):
	if wait:
		await ui.turn_started
	if !ui.override_chest:
		var card_destination:Variant
		
		if put_in_victory_chest:
			card_destination = victory_chest
		else:
			card_destination = $whatever_chest
		for card in %held_cards.get_children():
			if card.index == index:
				cards_in_hand.erase(card)
				card.reparent(card_destination)
				removed_cards.append(card)
				card.set_card_scale(Vector2(0.15, 0.15))
				
				card.visible = false
				card.left_clicked.disconnect(ui.play_card)
				card.do_offset_bullshit = false
				card.select_offset = 0
				
				#Redo the index
				for i in range(card_destination.get_children().size()):
					if card == card_destination.get_children()[i]:
						card.index = i
				
				#Redo the index
				if reindex:
					for i in range(%held_cards.get_children().size()):
						if card == %held_cards.get_children()[i]:
							card.index = i
				if x_offset > 0:
					x_offset -= card.size.x
		card_removed.emit()

func readd_card(index):
	print('Card readded')
	for card in victory_chest.get_children():
		if card.index == index:
			removed_cards.erase(card)
			card.reparent(%held_cards)
			cards_in_hand.erase(card)
			
			card.disabled = false
			card.left_clicked.connect(ui.play_card)
			card.do_offset_bullshit = true
			card.set_card_scale(Vector2(0.37, 0.37))
			
			#Redo the index
			for i in range(%held_cards.get_children().size()):
				if card == %held_cards.get_children()[i]:
					card.index = i
			for i in range(victory_chest.get_children().size()):
				if card == victory_chest.get_children()[i]:
					card.indx = i
			card_added.emit()

func replace_card(card_to_replace_index:int, card_to_add_number:String, carry_bonuses:bool = false):
	var bonuses
	var penalties
	if carry_bonuses:
		bonuses = get_card_from_index(card_to_replace_index).stats["Bonuses"]
		penalties = get_card_from_index(card_to_replace_index).stats["Penalties"]
	remove_card(card_to_replace_index, true, false, false)
	var card = add_card_from_resource(card_to_add_number, card_to_replace_index)
	if carry_bonuses:
		card.stats["Bonuses"] = bonuses
		card.stats["Penalties"] = penalties

@rpc("any_peer")
func remove_all_cards():
	print(ui.game.get_player().player_name + " has had all their cards removed!")
	for i in range(cards_in_hand.size()):
		remove_card(i, false, false)

# Disables the card with the matching index from the card hand, for the duration specified
func disable_card(index, duration):
	for card in %held_cards.get_children():
		if card.index == index:
			card.disabled = true
			card.disabled_time = duration

func block_input():
	for card in cards_in_hand:
		card.block_input = true

func allow_input():
	for card in cards_in_hand:
		card.block_input = false

func card_exists(index):
	for i in range(cards_in_hand.size()):
		if i == index:
			return true
	return false

func get_card_from_index(index):
	var daIndex = index
	while daIndex > cards_in_hand.size():
		daIndex -= cards_in_hand.size()
	for i in range(cards_in_hand.size()):
		if i == daIndex:
			return cards_in_hand[i]

func reindex_deck():
	for card in %held_cards.get_children():
		for i in range(%held_cards.get_children().size()):
			if card == %held_cards.get_children()[i]:
				card.index = i

@rpc("any_peer")
func return_random_card(exclude:int):
	var index = randi_range(0, cards_in_hand.size() - 1)
	while index == exclude:
		index = randi_range(0, cards_in_hand.size() - 1)
	
	var card_to_return:Dictionary = cards_in_hand[index].export()
	return card_to_return

func _on_card_disabled(card, value):
	print("on card disabled")
	if value == true:
		disabled_cards.append(card)
	if value == false:
		disabled_cards.erase(card)
		if card.statuses.has("Disabled!"):
			card.statuses.erase("Disabled!")

func _on_mouse_detection_area_entered(_area: Area2D) -> void:
	if !ui.is_in_preview && !focused:
		y_offset = -160
		focused = true


func _on_mouse_detection_area_exited(_area: Area2D) -> void:
	if !ui.is_in_preview && focused:
		y_offset = 0
		focused = false

func show_victory_chest_cards(from:Vector2):
	victory_chest.global_position.x = from.x - victory_chest.size.x
	if victory_chest.get_children() != []:
		victory_position = from.x - victory_chest.size.x - (victory_chest.get_children()[0].size.x * 1.4)
	
	victory_chest.visible = true
	for card in victory_chest.get_children():
		card.visible = true
	victory_chest.add_theme_constant_override("separation", -59.55)
	victory_seperation = 15

func hide_victory_chest_cards(to:Vector2):
	victory_seperation = -59.55
	victory_position = to.x - victory_chest.size.x
