extends Control

signal card_removed
signal card_added

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

@onready var ui = get_parent()

@onready var victory_chest = $victory_chest


var cards_in_hand = []
var removed_cards = []

var focused:bool = false


func generate_cards(cards_to_generate):
	for i in range(cards_to_generate.size()):
		var card = card_scene.instantiate()
		var stats_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + cards_to_generate[i] + ".tres"
		#print(stats_path)
		card.stats = load(stats_path)
		card.index = i
		cards_in_hand.append(card)
		card.left_clicked.connect(ui.play_card)
		card.right_clicked.connect(ui.card_preview.generate_card_preview)
		ui.turn_ended.connect(card._on_turn_ended)
		$held_cards.add_child(card)

@rpc("any_peer")
func add_card(export:Dictionary):
	var card = card_scene.instantiate()
	
	card.stats.card_name = export["Name"]
	card.stats.card_series = export["Series"]
	card.stats.card_number = export["Number"]
	card.stats.bonuses = export["Bonuses"]
	card.stats.penalties = export["Penalties"]
	card.stats.base_attack = export["Base Attack"]
	card.stats.base_defense = export["Base Defense"]
	card.stats.can_get_bonuses = export["Can Get Bonuses"]
	card.stats.ability_name = export["Ability"]
	card.stats.ability_description = export["Ability Description"]
	card.stats.one_use_ability = export["One Use Ability"]
	
	cards_in_hand.append(card)
	card.left_clicked.connect(ui.play_card)
	$held_cards.add_child(card)
	
	for i in range(%held_cards.get_children().size()):
		if card == %held_cards.get_children()[i]:
			card.index = i
	
	return card

func add_card_from_resource(number:String, forced_index:int = -1):
	var card = card_scene.instantiate()
	var stats_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + number + ".tres"
	#print(stats_path)
	card.stats = load(stats_path)
	cards_in_hand.append(card)
	card.left_clicked.connect(ui.play_card)
	card.right_clicked.connect(ui.card_preview.generate_card_preview)
	ui.turn_ended.connect(card._on_turn_ended)
	$held_cards.add_child(card)
	if forced_index == -1:
		card.index = cards_in_hand.size() - 1
	else:
		move_child(card, forced_index)
		reindex_deck()
	
	return card

@rpc("any_peer")
func remove_card(index, put_in_victory_chest:bool = true, reindex:bool = true):
	var card_destination:Variant
	
	if put_in_victory_chest:
		card_destination = $victory_chest
	else:
		card_destination = $whatever_chest
	for card in %held_cards.get_children():
		if card.index == index:
			cards_in_hand.erase(card)
			card.reparent(card_destination)
			removed_cards.append(card)
			
			card.disabled = true
			card.disabled_time = 0
			
			#Redo the index
			for i in range(card_destination.get_children().size()):
				if card == card_destination.get_children()[i]:
					card.index = i
			
			#Redo the index
			if reindex:
				for i in range(%held_cards.get_children().size()):
					if card == %held_cards.get_children()[i]:
						card.index = i
	card_removed.emit()

func readd_card(index):
	print('Card readded?')
	for card in victory_chest.get_children():
		if card.index == index:
			removed_cards.erase(card)
			card.reparent(%held_cards)
			cards_in_hand.erase(card)
			
			card.disabled = false
			
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
		bonuses = get_card_from_index(card_to_replace_index).stats.bonuses
		penalties = get_card_from_index(card_to_replace_index).stats.penalties
	remove_card(card_to_replace_index, false, false)
	var card = add_card_from_resource(card_to_add_number, card_to_replace_index)
	if carry_bonuses:
		card.stats.bonuses = bonuses
		card.stats.penalties = penalties

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
	print(card_to_return["Name"])
	return card_to_return


func _on_mouse_detection_area_entered(_area: Area2D) -> void:
	if !ui.is_in_preview && !focused:
		$card_hide.play("show")
		focused = true


func _on_mouse_detection_area_exited(_area: Area2D) -> void:
	if !ui.is_in_preview && focused:
		$card_hide.play("hide")
		focused = false
