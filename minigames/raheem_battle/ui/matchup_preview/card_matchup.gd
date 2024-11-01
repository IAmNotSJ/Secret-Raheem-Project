@tool
extends ExtraScreen

@onready var animation = $animation
@onready var card1 = $Card
@onready var card2 = $Card2

func _ready():
	card1.set_card_scale(Vector2(0.75, 0.75))
	card2.set_card_scale(Vector2(0.75, 0.75))

@rpc("any_peer")
func start(decision, card, opposing_card):
	#print('HELLOO???')
	
	card1.set_card_scale(Vector2(0.75, 0.75))
	card2.set_card_scale(Vector2(0.75, 0.75))
	
	ui.card_hand.block_input()
	screen_container.add_screen_queue(screen_container.CARD_MATCHUP)
	ui.is_in_preview = true
	load_card(card1, card)
	load_card(card2, opposing_card)
	animation.play("appear")
	
	await animation.animation_finished
	if decision == card["Side"]:
		animation.play("card1_win")
	elif decision == Player.Sides.TIE:
		animation.play("tie")
	else:
		animation.play("card2_win")

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		clear()

func load_card(card, export):
	#print(export["Number"])
	#card.stats = load("res://minigames/raheem_battle/cards/card_variants/stats/" + export["Number"] + ".tres")
	card.stats = card.return_stats_from_export(export)
	
	card.set_bonuses(export["Bonuses"])
	card.set_penalties(export["Penalties"])
	
	if card.stats["Ability Name"] == "Speeding":
		card.stats["Hide Stats"] = false
	card._on_stats_changed()

func clear():
	hide()
