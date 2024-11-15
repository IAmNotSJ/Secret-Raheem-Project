extends Node2D

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")

func _ready():
	var cards_to_generate = Saves.battle_deck["8 Cards"]
	for i in range(cards_to_generate.size()):
		var card = card_scene.instantiate()
		card.stats = card.return_stats_from_resource("res://minigames/raheem_battle/cards/card_variants/stats/" + cards_to_generate[i] + ".tres")
		card.index = i
		card.is_preview = true
		$held_cards.add_child(card)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		Transition.change_scene_to_preset("Main Menu")
