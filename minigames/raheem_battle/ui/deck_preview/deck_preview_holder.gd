extends ExtraScreen

signal card_chosen

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

@onready var message = $Message

var bonuses_to_add = [0, 0]

var affecting_card
#Needs an array of every exported card to display
func generate_deck(export_array, reason, ref_card):
	affecting_card = ref_card
	var card_scale:Vector2 = Vector2(0.5, 0.5)
	var cards_per_row:int = 4
	var seperation:Vector2 = Vector2(100, 100)
	match ui.game.match_rules["Deck Size"]:
		"8 Cards":
			card_scale = Vector2(0.5, 0.5)
			cards_per_row = 4
		"9 Cards":
			card_scale = Vector2(0.4, 0.4)
			cards_per_row = 5
		"10 Cards":
			card_scale = Vector2(0.4, 0.4)
			cards_per_row = 5
		"11 Cards":
			card_scale = Vector2(0.35, 0.35)
			cards_per_row = 6
			seperation = Vector2(50, 100)
		"12 Cards":
			card_scale = Vector2(0.35, 0.35)
			cards_per_row = 6
			seperation = Vector2(50, 50)
	$Row1.add_theme_constant_override("separation", seperation.x)
	$Row2.add_theme_constant_override("separation", seperation.y)
	for i in range(export_array.size()):
		var card = card_scene.instantiate()
		card.do_offset_bullshit = false
		
		card.set_card_scale(card_scale)
		
		#Change the stats
		
		card.stats = card.return_stats_from_export(export_array[i])
		card.index = export_array[i]["Index"]
		
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
				message.text = "Pick a card to steal the stats of"
				card.left_clicked.connect(_card_selected_extra_space)
			"Annoying":
				message.text = "Pick a card to remove"
				card.left_clicked.connect(_card_selected_annoying)
		
		if i < cards_per_row:
			$Row1.add_child(card)
		else:
			$Row2.add_child(card)
	
	#ui.card_hand.block_input()
	
	match reason:
		"Extra Space":
			$Cancel.visible = true

func _card_selected_extra_space(daCard):
	var index = daCard.index
	if index >= affecting_card.index:
		index += 1
	affecting_card.add_bonus_attack(daCard.stats["True Attack"], "Extra Space")
	affecting_card.add_bonus_defense(daCard.stats["True Defense"], "Extra Space")
	affecting_card.apply_bonuses()
	ui.card_hand.replace_card(daCard.index, "-127", false)
	clear()

func _card_selected_catalyst(card):
	ui.card_hand.remove_card(card.index)
	card_chosen.emit()
	
	clear()

func _card_selected_other_priorities(card):
	var chosen_card = ui.card_hand.get_card_from_index(card.index)
	chosen_card.add_bonus_attack(bonuses_to_add[0], "Other Priorities")
	chosen_card.add_bonus_defense(bonuses_to_add[0], "Other Priorities")
	chosen_card.apply_bonuses()
	
	
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
	clear()

func _card_selected_annoying(daCard):
	ui.card_hand.remove_card(daCard.index)
	clear()

func clear():
	for child in $Row1.get_children():
		child.queue_free()
	for child in $Row2.get_children():
		child.queue_free()
	hide()
	message.text = ""


func _on_click_detection_pressed() -> void:
	if $Cancel.visible:
		clear()
