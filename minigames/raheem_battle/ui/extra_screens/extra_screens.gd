extends Node2D

signal finished

@onready var card_preview_holder = $card_preview_holder
@onready var deck_preview_holder = $deck_preview_holder
@onready var decision_holder = $decision_holder
@onready var geometry = $geometry
@onready var card_matchup = $card_matchup
@onready var mouse_control = $mouse_control
@onready var paper = $paper

var screens_to_show:Array[ExtraScreen] = []

func start_showing_screens():
	for screen in screens_to_show:
		screen.visible = true
		await screen.hidden
	screens_to_show = []
	finished.emit()
