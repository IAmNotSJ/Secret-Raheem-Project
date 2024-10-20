extends ExtraScreen

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

func generate_card_preview(stats, back:bool = false, force:bool = true):
	if !ui.is_in_preview:
		var card = card_scene.instantiate()
		card.stats = stats
		card.block_input = true
		card.set_card_scale(Vector2(1, 1))
		ui.is_in_preview = true
		
		#card.position.y += 50
		
		$card_container.add_child(card)
		
		#var tween = get_tree().create_tween()
		#tween.tween_property($Sprite, "modulate", Color.RED, 1)
		#tween.tween_property($Sprite, "scale", Vector2(), 1)
		#tween.tween_callback($Sprite.queue_free)
		
		ui.card_hand.block_input()
		screen_container.add_screen_queue(screen_container.CARD_PREVIEW, back)
		if force:
			screen_container.start_showing_screens()
		

@rpc("any_peer")
func generate_preview_from_export(export, back:bool = false, force:bool = false):
	print("Code is being executed for card preview")
	ui.is_in_preview = true
	ui.card_hand.block_input()
	var card = card_scene.instantiate()
	card.block_input = true
	card.set_card_scale(Vector2(1, 1))
	
	
	
	card.stats.card_name = export["Name"]
	card.stats.card_series = export["Series"]
	card.stats.card_number = export["Number"]
	card.stats.bonuses = export["Bonuses"]
	card.stats.penalties = export["Penalties"]
	card.stats.base_attack = export["Base Attack"]
	card.stats.base_defense = export["Base Defense"]
	card.stats.can_get_bonuses = export["Can Get Bonuses"]
	card.stats.ability_name = export["Ability"]
	card.stats.ability_description = export["Ability Description"]
	card.stats.one_use_ability = export["One Use Ability"]
	card.ability_used = export["Ability Used"]
	card.stats.hide_stats = export["Hide Stats"]
	card.stats.is_human = export["Is Human"]
	card.stats.has_hands = export["Has Hands"]
	card.stats.should_remove = export["Should Remove"]
	card.index = export["Index"]
	
	$card_container.add_child(card)
	
	screen_container.add_screen_queue(screen_container.CARD_PREVIEW, back)
	if force:
		screen_container.start_showing_screens()

func _unhandled_input(event):
	if visible:
		if event.is_action_pressed("back"):
			print('card preview is being hidden')
			if $card_container.get_children() != []:
				for card in $card_container.get_children():
					card.queue_free()
			hide()
