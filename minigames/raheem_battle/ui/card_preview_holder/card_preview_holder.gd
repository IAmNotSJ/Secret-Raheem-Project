extends ExtraScreen

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

func generate_card_preview(stats, message:String = "", back:bool = false, force:bool = true):
		var card = card_scene.instantiate()
		card.stats = stats
		card.block_input = true
		card.set_card_scale(Vector2(1, 1))
		
		$message.text = message
		
		#card.position.y += 50
		
		$card_container.add_child(card)
		
		#var tween = get_tree().create_tween()
		#tween.tween_property($Sprite, "modulate", Color.RED, 1)
		#tween.tween_property($Sprite, "scale", Vector2(), 1)
		#tween.tween_callback($Sprite.queue_free)
		
		screen_container.add_screen_queue(screen_container.CARD_PREVIEW, back)
		if force:
			screen_container.start_showing_screens()
		

@rpc("any_peer")
func generate_preview_from_export(export, message:String = "", back:bool = false, force:bool = false):
	print("Code is being executed for card preview")
	var card = card_scene.instantiate()
	card.block_input = true
	card.set_card_scale(Vector2(1, 1))
	
	$message.text = message
	
	
	card.stats = card.return_stats_from_export(export)
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
