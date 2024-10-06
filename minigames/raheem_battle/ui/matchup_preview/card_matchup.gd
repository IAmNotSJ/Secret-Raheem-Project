extends ExtraScreen

@onready var animation = $animation
@onready var card1 = $Card
@onready var card2 = $Card2

@rpc("any_peer")
func start(decision, card, opposing_card):
	print('HELLOO???')
	ui.card_hand.block_input()
	screen_container.add_screen_queue(screen_container.CARD_MATCHUP)
	ui.is_in_preview = true
	load_card(card1, card)
	load_card(card2, opposing_card)
	animation.play("appear")
	
	await animation.animation_finished
	if decision == card["Side"]:
		animation.play("card1_win")
	else:
		animation.play("card2_win")

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		clear()

func load_card(card, export):
	#print(export["Number"])
	#card.stats = load("res://minigames/raheem_battle/cards/card_variants/stats/" + export["Number"] + ".tres")
	card.stats.card_name = export["Name"]
	card.stats.card_series = export["Series"]
	card.stats.card_number = export["Number"]
	card.stats.base_attack = export["Base Attack"]
	card.stats.base_defense = export["Base Defense"]
	card.stats.can_get_bonuses = export["Can Get Bonuses"]
	card.stats.set_bonuses(export["Bonuses"])
	card.stats.set_penalties(export["Penalties"])
	card.stats.ability_name = export["Ability"]
	card.stats.ability_description = export["Ability Description"]
	card.stats.one_use_ability = export["One Use Ability"]
	card.ability_used = export["Ability Used"]
	card.stats.hide_stats = export["Hide Stats"]
	card.stats.is_human = export["Is Human"]
	card.stats.has_hands = export["Has Hands"]
	card.stats.should_remove = export["Should Remove"]

func clear():
	ui.card_hand.allow_input()
	ui.is_in_preview = false
	hide()
