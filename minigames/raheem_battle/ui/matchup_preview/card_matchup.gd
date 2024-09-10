extends ExtraScreen

@rpc("any_peer")
func start():
	ui.card_hand.block_input()
	screen_container.screens_to_show.push_front(screen_container.card_matchup)
	ui.is_in_preview = true

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		clear()

func clear():
	ui.card_hand.allow_input()
	ui.is_in_preview = false
	hide()
