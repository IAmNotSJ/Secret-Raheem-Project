extends ExtraScreen

signal decision_made()

# Shitty way of reading the decision, but whatever
var last_decision:bool

func generate_message(reason:String, card):
	var text_to_show = ""
	var choices = ["True", "False"]
	match reason:
		"Categorical Knowledge":
			text_to_show = "Choose which stat type to use"
			choices = ["Attack", "Defense"]
			$True.pressed.connect(_on_decision_categorical_knowledge.bind(true, card))
			$False.pressed.connect(_on_decision_categorical_knowledge.bind(false, card))
	$Message.text = text_to_show
	
	$True.text = choices[0]
	$False.text = choices[1]
	
	ui.is_in_preview = true
	ui.card_hand.block_input()

func _on_decision_categorical_knowledge(decision, card):
	if decision == true:
		card.stats.base_attack = 0
		card.stats.base_defense = 0
		card.stats.set_bonus_attack(6, "Categorical Knowledge")
		card.stats.set_bonus_defense(0, "Categorical Knowledge")
	else:
		card.stats.base_attack = 0
		card.stats.base_defense = 0
		card.stats.set_bonus_attack(0, "Categorical Knowledge")
		card.stats.set_bonus_defense(6, "Categorical Knowledge")
	clear()
	decision_made.emit()

func clear():
	ui.card_hand.allow_input()
	ui.is_in_preview = false
	
	$True.pressed.disconnect(_on_decision_categorical_knowledge)
	$False.pressed.disconnect(_on_decision_categorical_knowledge)
	
	hide()
