extends Node2D

enum {
	INITIAL,
	HOST,
	JOIN,
	ADVANCED,
	QUIZ
}
var current_screen = INITIAL

@onready var manager = get_parent()

var display_name:String = "Random Player"

var upnp:bool = false

func _ready():
	_switch_screen(INITIAL)
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

func _switch_screen(screen, show_title = true):
	match screen:
		INITIAL:
			$Initial.visible = true
			$Host.visible = false
			$Join.visible = false
			$Advanced.visible = false
			$Quiz.visible = false
		HOST:
			$Initial.visible = false
			$Host.visible = true
			$Join.visible = false
			$Advanced.visible = false
			$Quiz.visible = false
		JOIN:
			$Initial.visible = false
			$Host.visible = false
			$Join.visible = true
			$Advanced.visible = false
			$Quiz.visible = false
		ADVANCED:
			$Initial.visible = false
			$Host.visible = false
			$Join.visible = false
			$Advanced.visible = true
			$Quiz.visible = false
		QUIZ:
			$Initial.visible = false
			$Host.visible = false
			$Join.visible = false
			$Advanced.visible = false
			$Quiz.visible = true
	$Title.visible = show_title
	current_screen = screen


func _on_host_pressed():
	_switch_screen(HOST)
func _on_join_pressed():
	_switch_screen(JOIN)
func _on_advanced_pressed():
	_switch_screen(ADVANCED)
func _on_quiz_pressed():
	_switch_screen(QUIZ, false)

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



