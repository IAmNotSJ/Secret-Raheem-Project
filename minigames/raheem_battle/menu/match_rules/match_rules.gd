extends Node2D

@onready var manager = get_parent().get_parent().get_parent()

func _on_card_num_item_selected(index: int) -> void:
	manager.match_rules["Deck Size"] = %CardNum.answers[index]
	var maximum = 0
	match index:
		0:
			maximum = 8
		1:
			maximum = 9
		2:
			maximum = 10
		3:
			maximum = 11
		4:
			maximum = 12
	maximum -= 1
	%CardsToWin.max_value = maximum

func _on_cards_to_win_value_changed(value: float) -> void:
	get_parent().get_parent().get_parent().match_rules["Cards To Win"] = value
