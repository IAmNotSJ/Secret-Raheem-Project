extends Control

@onready var ui = get_parent()
const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

var bonuses_to_add = [0, 0]
#Needs an array of every exported card to display
func generate_deck(export_array, reason):
	for i in range(export_array.size()):
		var card = card_scene.instantiate()
		card.get_node("visible").scale = Vector2(0.5, 0.5)
		
		#Change the stats
		
		card.stats.card_name = export_array[i]["Name"]
		card.stats.card_series = export_array[i]["Series"]
		card.stats.card_number = export_array[i]["Number"]
		card.stats.bonuses = export_array[i]["Bonuses"]
		card.stats.penalties = export_array[i]["Penalties"]
		card.stats.base_attack = export_array[i]["Base Attack"]
		card.stats.base_defense = export_array[i]["Base Defense"]
		card.stats.can_get_bonuses = export_array[i]["Can Get Bonuses"]
		card.stats.ability_name = export_array[i]["Ability"]
		card.stats.ability_description = export_array[i]["Ability Description"]
		card.stats.one_use_ability = export_array[i]["One Use Ability"]
		card.index = export_array[i]["Index"]
		
		match reason:
			"Catalyst":
				card.selected.connect(_card_selected_catalyst)
			"Other Priorities":
				card.selected.connect(_card_selected_other_priorities)
		
		if i < 4:
			$Row1.add_child(card)
		else:
			$Row2.add_child(card)
		
		ui.card_hand.block_input()

func _card_selected_catalyst(card):
	ui.card_hand.remove_card(card.index)
	clear()

func _card_selected_other_priorities(card):
	ui.card_hand.get_card_from_index(card.index).add_bonus_attack(bonuses_to_add[0], "Other Priorities")
	ui.card_hand.get_card_from_index(card.index).add_bonus_defense(bonuses_to_add[0], "Other Priorities")
	bonuses_to_add = [0, 0]

func clear():
	for child in $Row1.get_children():
		child.queue_free()
	for child in $Row2.get_children():
		child.queue_free()
	ui.card_hand.allow_input()
	ui.is_in_preview = false
