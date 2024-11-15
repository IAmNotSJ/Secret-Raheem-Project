@tool
extends ExtraScreen

@onready var animation = $animation
@onready var leave_timer = $"auto-leave"

@onready var card1 = $Card
@onready var card2 = $Card2

var hide_opposing:bool = false
var hide_self:bool = false

func _ready():
	card1.set_card_scale(Vector2(0.75, 0.75))
	card2.set_card_scale(Vector2(0.75, 0.75))

@rpc("any_peer")
func start(decision, card, opposing_card):
	
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
	
	leave_timer.start(3)

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		clear()

func load_card(card, export):
	card.stats = card.return_stats_from_export(export)
	
	card.set_bonuses(export["Bonuses"])
	card.set_penalties(export["Penalties"])
	
	if card.stats["Ability Name"] == "Speeding":
		card.stats["Hide Stats"] = false
	
	if card == card2 and hide_opposing:
		card.stats["Ability Name"] = ""
		card.stats["Hide Stats"] = true
		card.stats["Card Name"] = "Hidden Card"
		card.stats["Card Number"] = "-151"
		card.stats["Card Series"] = "Hidden"
		
		card.stats["Can Get Bonuses"] = true
		card.stats["One Use Ability"] = false
		card.stats["Should Remove"] = true
		card.stats["Is Human"] = false
		card.stats["Has Hands"] = false
		card.stats["Fire"] = false
	if card == card1 and hide_self:
		card.stats["Ability Name"] = ""
		card.stats["Hide Stats"] = true
		card.stats["Card Name"] = "Hidden Card"
		card.stats["Card Number"] = "-151"
		card.stats["Card Series"] = "Hidden"
		
		card.stats["Can Get Bonuses"] = true
		card.stats["One Use Ability"] = false
		card.stats["Should Remove"] = true
		card.stats["Is Human"] = false
		card.stats["Has Hands"] = false
		card.stats["Fire"] = false
	card._on_stats_changed()

func clear():
	hide()
	if animation.is_playing():
		animation.stop()
	if leave_timer.time_left != 0:
		leave_timer.stop()


func _on_autoleave_timeout() -> void:
	if visible:
		clear()
