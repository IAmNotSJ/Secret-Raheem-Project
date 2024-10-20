extends ExtraScreen

signal card_chosen

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

var bonuses_to_add = [0, 0]
#Needs an array of every exported card to display
func generate_deck(export_array, reason):
	for i in range(export_array.size()):
		var card = card_scene.instantiate()
		card.set_card_scale(Vector2(0.5, 0.5))
		card.do_offset_bullshit = false
		
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
		card.stats.should_remove = export_array[i]["Should Remove"]
		card.stats.hide_stats = export_array[i]["Hide Stats"]
		card.stats.is_human = export_array[i]["Is Human"]
		card.stats.has_hands = export_array[i]["Has Hands"]
		card.index = export_array[i]["Index"]
		
		match reason:
			"Catalyst":
				card.left_clicked.connect(_card_selected_catalyst)
			"Other Priorities":
				card.left_clicked.connect(_card_selected_other_priorities)
			"Placeholder":
				card.left_clicked.connect(_card_selected_placeholder)
			"Extra Space":
				card.left_clicked.connect(_card_selected_extra_space)
		
		if i < 4:
			$Row1.add_child(card)
		else:
			$Row2.add_child(card)
	
	ui.card_hand.block_input()
	
	match reason:
		"Extra Space":
			$Cancel.visible = true

func _card_selected_extra_space(daCard):
	var card = ui.card_hand.get_card_from_index(daCard.index)
	ui.card_to_play.add_bonus_attack(card.stats.true_attack, "Extra Space")
	ui.card_to_play.add_bonus_defense(card.stats.true_defense, "Extra Space")
	ui.card_hand.replace_card(card.index, "-1", false)
	
	clear()

func _card_selected_catalyst(card):
	ui.card_hand.remove_card(card.index)
	card_chosen.emit()
	
	clear()

func _card_selected_other_priorities(card):
	ui.card_hand.get_card_from_index(card.index).stats.add_bonus_attack(bonuses_to_add[0], "Other Priorities")
	ui.card_hand.get_card_from_index(card.index).stats.add_bonus_defense(bonuses_to_add[0], "Other Priorities")
	bonuses_to_add = [0, 0]
	card_chosen.emit()
	
	clear()

func _card_selected_placeholder(card):
	ui.card_to_play.stats.ability_name = card.stats.ability_name
	ui.card_to_play.stats.ability_description = card.stats.ability_description
	ui.card_to_play.stats.should_remove = card.stats.should_remove
	ui.card_to_play.stats.one_use_ability = card.stats.one_use_ability
	ui.card_to_play.stats.hide_stats = card.stats.hide_stats
	card_chosen.emit()
	clear()

func clear():
	for child in $Row1.get_children():
		child.queue_free()
	for child in $Row2.get_children():
		child.queue_free()
	ui.card_hand.allow_input()
	ui.is_in_preview = false
	hide()
