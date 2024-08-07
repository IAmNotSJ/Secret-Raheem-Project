extends Control

@onready var ui = get_parent()

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

func generate_card_preview(stats):
	if !ui.is_in_preview:
		var card = card_scene.instantiate()
		card.stats = stats
		card.block_input = true
		card.get_node("visible").scale = Vector2(1, 1)
		ui.is_in_preview = true
		
		$card_preview_center.add_child(card)
		
		ui.card_hand.block_input()

@rpc("any_peer")
func generate_preview_from_export(export):
	var card = card_scene.instantiate()
	card.block_input = true
	card.get_node("visible").scale = Vector2(1, 1)
	ui.is_in_preview = true
	
	card.stats.card_name = export["Name"]
	card.stats.card_series = export["Series"]
	card.stats.card_number = export["Number"]
	card.stats.bonuses = export["Bonuses"]
	card.stats.penalties = export["Penalties"]
	card.stats.base_attack = export["Base Attack"]
	card.stats.base_defense = export["Base Defense"]
	card.stats.size = export["Size"]
	card.stats.can_get_bonuses = export["Can Get Bonuses"]
	card.stats.ability_name = export["Ability"]
	card.stats.ability_description = export["Ability Description"]
	card.stats.one_use_ability = export["One Use Ability"]
	card.index = export["Index"]
	
	$card_preview_center.add_child(card)
	
	ui.card_hand.block_input()

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		if $card_preview_center.get_children() != []:
			for card in $card_preview_center.get_children():
				card.queue_free()
			ui.is_in_preview = false
			ui.card_hand.allow_input()
