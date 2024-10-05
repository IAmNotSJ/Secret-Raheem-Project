extends Node2D

enum {
	INITIAL,
	HOST,
	JOIN,
	ADVANCED,
	QUIZ,
	DECK
}
var current_screen = INITIAL

@onready var manager = get_parent()

@onready var initial = $ALL/Initial
@onready var advanced = $ALL/Advanced
@onready var host = $ALL/Host
@onready var join = $ALL/Join
@onready var quiz = $ALL/Quiz

@onready var animation = $animation
@onready var camera = $camera

var display_name:String = "Random Player"

var upnp:bool = false

func _ready():
	#_switch_screen(INITIAL)
	pass
func _unhandled_input(event):
	if event.is_action_pressed("back"):
		match current_screen:
			INITIAL:
				pass
			HOST:
				_switch_screen(INITIAL)
			JOIN:
				_switch_screen(INITIAL)
			ADVANCED:
				_switch_screen(INITIAL)
			QUIZ:
				_switch_screen(INITIAL)
			DECK:
				if !$ALL/deck_builder.is_in_preview:
					_switch_screen(INITIAL)

func _switch_screen(screen):
	match screen:
		INITIAL:
			match current_screen:
				HOST:
					animation.play('host-initial')
				JOIN:
					animation.play('join-initial')
				ADVANCED:
					animation.play('advanced-initial')
				QUIZ:
					animation.play('quiz-initial')
				DECK:
					animation.play('deck-initial')
		HOST:
			animation.play('initial-host')
		JOIN:
			animation.play('initial-join')
		ADVANCED:
			animation.play('initial-advanced')
		QUIZ:
			animation.play('initial-quiz')
		DECK:
			animation.play('initial-deck')
	current_screen = screen
	
	if screen == QUIZ:
		await animation.animation_finished
		camera.can_scroll = true
	else:
		camera.can_scroll = false


func _on_host_pressed():
	_switch_screen(HOST)
func _on_join_pressed():
	_switch_screen(JOIN)
func _on_advanced_pressed():
	_switch_screen(ADVANCED)
func _on_quiz_pressed():
	_switch_screen(QUIZ)
func _on_deck_pressed():
	_switch_screen(DECK)

func _on_display_name_box_text_changed(new_text):
	display_name = new_text


func _on_join_room_pressed():
	if !upnp:
		manager.on_join_pressed("localhost")
	elif %address_bar.text != "":
		manager.on_join_pressed(%address_bar.text)
func _on_create_room_pressed():
	manager.on_host_pressed()


func _on_check_box_toggled(toggled_on):
	upnp = toggled_on
