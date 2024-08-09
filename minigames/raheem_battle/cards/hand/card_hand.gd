extends Control

signal card_removed
signal card_brought_back

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

@onready var ui = get_parent()


var cards_in_hand = []
var removed_cards = []

func generate_cards(cards_to_generate):
	for i in range(cards_to_generate.size()):
		var card = card_scene.instantiate()
		var stats_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + cards_to_generate[i] + ".tres"
		card.stats = load(stats_path)
		card.index = i
		cards_in_hand.append(card)
		card.selected.connect(ui.play_card)
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
	card.selected.connect(ui.play_card)
	$held_cards.add_child(card)
	
	for i in range(%held_cards.get_children().size()):
		if card == %held_cards.get_children()[i]:
			card.index = i

@rpc("any_peer")
func remove_card(index, victory_chest:bool = true):
	for card in %held_cards.get_children():
		if card.index == index:
			cards_in_hand.erase(card)
			if victory_chest:
				card.reparent($victory_chest)
				removed_cards.append(card)
				
				card.disabled = true
				card.disabled_time = 0
				
				#Redo the index
				for i in range($victory_chest.get_children().size()):
					if card == $victory_chest.get_children()[i]:
						card.index = i
			else:
				card.queue_free()
			
			#Redo the index
			for i in range(%held_cards.get_children().size()):
				if card == %held_cards.get_children()[i]:
					card.index = i
	card_removed.emit()

func readd_card(index):
	print('Card readded?')
	for card in $victory_chest.get_children():
		if card.index == index:
			removed_cards.erase(card)
			card.reparent(%held_cards)
			cards_in_hand.erase(card)
			
			card.disabled = false
			
			#Redo the index
			for i in range(%held_cards.get_children().size()):
				if card == %held_cards.get_children()[i]:
					card.index = i
			for i in range($victory_chest.get_children().size()):
				if card == $victory_chest.get_children()[i]:
					card.indx = i

@rpc("any_peer")
func remove_all_cards():
	print(ui.game.get_player().player_name + " has had all their cards removed!")
	for card in cards_in_hand:
		remove_card(card.index)

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

func get_card_from_index(index):
	for i in range(cards_in_hand.size()):
		if i == index:
			return cards_in_hand[i]
