class_name CardSnap

extends ColorRect

signal locked
signal unlocked

@onready var deck_builder = get_parent().get_parent().get_parent()

var card :
	set(value):
		card = value
@export var deck_index:int = 0

func _ready():
	$snap_text.text = "SLOT " + str(deck_index)
func lock_card(daCard):
	if card == null:
		card = daCard
		card.global_position = $snap.global_position
		
		Saves.battle_deck[deck_builder.cur_deck][deck_index - 1] = card.stats["Card Number"]
		deck_builder.cards_removed.append(card.stats["Card Number"])
		card.reparent(self)
		card.snap = self
		
		locked.emit()
		
		for leCard in deck_builder.get_node("ScrollContainer/card_container").get_children():
			leCard.original_position = leCard.position
