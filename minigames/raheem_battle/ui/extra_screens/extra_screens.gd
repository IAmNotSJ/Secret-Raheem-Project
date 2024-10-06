extends Node2D

signal finished

@onready var ui = get_parent()
enum {
	CARD_PREVIEW,
	DECK_PREVIEW,
	DECISION_HOLDER,
	GEOMETRY,
	CARD_MATCHUP,
	MOUSE_CONTROL,
	PAPER
}
@onready var card_preview_holder = $card_preview_holder
@onready var deck_preview_holder = $deck_preview_holder
@onready var decision_holder = $decision_holder
@onready var geometry = $geometry
@onready var card_matchup = $card_matchup
@onready var mouse_control = $mouse_control
@onready var paper = $paper

var screens_to_show:Array[ExtraScreen] = []
var showing_screens:bool = false

func _process(_delta: float) -> void:
	if screens_to_show.size() > 0 and showing_screens:
		if screens_to_show[0].visible == false:
			screens_to_show.remove_at(0)
			print("SCREEN QUEUE: " + str(screens_to_show))
			if screens_to_show.size() > 0:
				screens_to_show[0].visible = true
			else:
				finished.emit()
				showing_screens = false

@rpc("any_peer")
func add_screen_queue(screenEnum, end:bool = false):
	var screen
	match screenEnum:
		CARD_PREVIEW:
			screen = $card_preview_holder
		DECK_PREVIEW:
			screen = $deck_preview_holder
		DECISION_HOLDER:
			screen = $decision_holder
		GEOMETRY:
			screen = $geometry
		CARD_MATCHUP:
			screen = $card_matchup
		MOUSE_CONTROL:
			screen = $mouse_control
		PAPER:
			screen = $paper
	#print(str(screen) + "HAS BEEN ADDED FOR " + get_parent().get_parent().get_player().player_name)
	if end:
		screens_to_show.push_back(screen)
	else:
		screens_to_show.push_front(screen)
	print("SCREEN QUEUE: " + str(screens_to_show))

func start_showing_screens():
	if screens_to_show.size() > 0:
		print("--------STARTING TO SHOW SCREENS--------")
		screens_to_show[0].visible = true
		showing_screens = true


func _on_finished() -> void:
	ui.is_in_preview = false
	ui.card_hand.allow_input()
