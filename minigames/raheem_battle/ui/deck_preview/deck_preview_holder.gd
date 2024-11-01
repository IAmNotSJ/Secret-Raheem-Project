extends ExtraScreen

signal card_chosen

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

@onready var message = $Message

var bonuses_to_add = [0, 0]

var affecting_card
#Needs an array of every exported card to display
func generate_deck(export_array, reason, ref_card):
	affecting_card = ref_card
	#print('----------------DECK PREVIEW MADE!!-----------------')
	for i in range(export_array.size()):
		var card = card_scene.instantiate()
		card.set_card_scale(Vector2(0.5, 0.5))
		card.do_offset_bullshit = false
		
		#Change the stats
		
		card.stats = card.return_stats_from_export(export_array[i])
		card.index = i
		
		match reason:
			"Catalyst":
				card.left_clicked.connect(_card_selected_catalyst)
				message.text = "Pick a card to remove from your deck"
			"Other Priorities":
				card.left_clicked.connect(_card_selected_other_priorities)
			"Brands":
				card.left_clicked.connect(_card_selected_brands)
				message.text = "Pick a card to copy the ability of"
			"Extra Space":
				card.left_clicked.connect(_card_selected_extra_space)
		
		if i < 4:
			$Row1.add_child(card)
		else:
			$Row2.add_child(card)
	
	#ui.card_hand.block_input()
	
	match reason:
		"Extra Space":
			$Cancel.visible = true

func _card_selected_extra_space(daCard):
	var card = ui.card_hand.get_card_from_index(daCard.index)
	ui.card_to_play.add_bonus_attack(card.stats["True Attack"], "Extra Space")
	ui.card_to_play.add_bonus_defense(card.stats["True Defense"], "Extra Space")
	ui.card_hand.replace_card(card.index, "-1", false)
	
	clear()

func _card_selected_catalyst(card):
	ui.card_hand.remove_card(card.index)
	card_chosen.emit()
	
	clear()

func _card_selected_other_priorities(card):
	ui.card_hand.get_card_from_index(card.index).add_bonus_attack(bonuses_to_add[0], "Other Priorities")
	ui.card_hand.get_card_from_index(card.index).add_bonus_defense(bonuses_to_add[0], "Other Priorities")
	bonuses_to_add = [0, 0]
	card_chosen.emit()
	
	clear()

func _card_selected_brands(card):
	if affecting_card != null:
		affecting_card.stats["Ability Name"] = card.stats["Ability Name"]
		affecting_card.stats["Ability Description"] = card.stats["Ability Description"]
		affecting_card.stats["Should Remove"] = card.stats["Should Remove"]
		affecting_card.stats["One Use Ability"] = card.stats["One Use Ability"]
		affecting_card.stats["Hide Stats"] = card.stats["Hide Stats"]
		
		ui.starting_game_card_effects([affecting_card])
		
		affecting_card.apply_bonuses()
		affecting_card.apply_penalties()
		affecting_card.changed.emit()
		card_chosen.emit()
	else:
		print('ERM!! CARD IS NULL IN THE DECK PREVIEW HOLDER!!')
	clear()

func clear():
	#print('deck preview cleared!')
	for child in $Row1.get_children():
		child.queue_free()
	for child in $Row2.get_children():
		child.queue_free()
	hide()
	message.text = ""
