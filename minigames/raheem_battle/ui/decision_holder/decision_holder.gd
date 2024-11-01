extends ExtraScreen

signal decision_made()
signal exited()

# Shitty way of reading the decision, but whatever
var last_decision:bool

var cancelled:bool = false

func generate_message(reason:String, card):
	var text_to_show = ""
	var bottom_text = ""
	var choices = ["True", "False"]
	match reason:
		"Categorical Knowledge":
			text_to_show = "Choose which stat type to use"
			choices = ["Attack", "Defense"]
			$True.pressed.connect(_on_decision_categorical_knowledge.bind(true, card))
			$False.pressed.connect(_on_decision_categorical_knowledge.bind(false, card))
		"Legal Fees":
			text_to_show = "Would you like to spend 200 copper coins to play this card?"
			bottom_text = "Copper Coins: " + str(Saves.playerInfo["Copper Coins"])
			choices = ["Buy", "Cancel"]
			$True.pressed.connect(_on_decision_legal_fees.bind(true, card))
			$False.pressed.connect(_on_decision_legal_fees.bind(false, card))
	$Message.text = text_to_show
	$bottom_message.text = bottom_text
	
	$True.text = choices[0]
	$False.text = choices[1]
	
	cancelled = false
	
	screen_container.add_screen_queue(screen_container.DECISION_HOLDER, true)
	screen_container.start_showing_screens()

func _on_decision_categorical_knowledge(decision, card):
	if decision == true:
		card.stats["Base Attack"] = 0
		card.stats["Base Defense"] = 0
		card.set_bonus_attack(6, "Categorical Knowledge")
		card.set_bonus_defense(0, "Categorical Knowledge")
	else:
		card.stats["Base Attack"] = 0
		card.stats["Base Defense"] = 0
		card.set_bonus_attack(0, "Categorical Knowledge")
		card.set_bonus_defense(6, "Categorical Knowledge")
	card.apply_bonuses()
	card.apply_penalties()
	clear()
	decision_made.emit()
	$True.pressed.disconnect(_on_decision_categorical_knowledge)
	$False.pressed.disconnect(_on_decision_categorical_knowledge)

func _on_decision_legal_fees(decision, _card):
	if decision == true:
		if global.can_remove_coins(200):
			global.remove_coins(200)
			decision_made.emit()
			clear()
		else:
			$Message.text = "You do not have enough copper coins to play this card!"
	else:
		cancelled = true
		clear()
		exited.emit()
	$True.pressed.disconnect(_on_decision_legal_fees)
	$False.pressed.disconnect(_on_decision_legal_fees)

func clear():
	hide()
