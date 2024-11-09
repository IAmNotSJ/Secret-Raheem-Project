class_name CardSnap

extends ColorRect

signal locked
signal unlocked

var card :
	set(value):
		card = value
		if card == null:
			print("SNAP " + str(deck_index) + " IS NULL")
@export var deck_index:int = 0

func _ready():
	$snap_text.text = "SLOT " + str(deck_index)
func lock_card(daCard):
	if card == null:
		card = daCard
		card.global_position = $snap.global_position
		
		Saves.battle_deck["Card " + str(deck_index)] = card.stats["Card Number"]
		#print(Saves.battle_deck)
		card.get_parent().get_parent().get_parent().cards_removed.append(card.stats["Card Number"])
		#print(card.get_parent().get_parent().get_parent().cards_removed)
		card.reparent(self)
		card.snap = self
		
		locked.emit()
		
		for leCard in get_parent().get_parent().get_node("ScrollContainer/card_container").get_children():
			leCard.original_position = leCard.position
