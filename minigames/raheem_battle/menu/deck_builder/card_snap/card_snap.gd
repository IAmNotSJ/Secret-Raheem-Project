class_name CardSnap

extends ColorRect

var card
@export var deck_index:int = 0

func _ready():
	$snap_text.text = "SLOT " + str(deck_index)
func lock_card(daCard):
	if card == null:
		card = daCard
		card.global_position = $snap.global_position
		
		Saves.battle_deck["Card " + str(deck_index)] = card.stats.card_number
		#print(Saves.battle_deck)
		#print("Saved to " + "card " + str(deck_index) + " the card " + card.stats.card_name)
		card.get_parent().get_parent().get_parent().cards_removed.append(card.stats.card_number)
		#print(card.get_parent().get_parent().get_parent().cards_removed)
		card.reparent(self)
		card.snap = self
		
		for leCard in get_parent().get_parent().get_node("ScrollContainer/card_container").get_children():
			leCard.original_position = leCard.position
