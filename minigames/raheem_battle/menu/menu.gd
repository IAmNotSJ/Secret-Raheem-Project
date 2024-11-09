extends Node2D

enum {
	INITIAL,
	HOST,
	JOIN,
	ADVANCED,
	QUIZ,
	DECK,
	PROFILE
}
var current_screen = INITIAL


@onready var initial_buttons = [%Host, %Join, %Deck, %Profile, %Quiz, %Advanced]

const popup_scene = preload("res://minigames/raheem_battle/menu/popup/popup.tscn")
var in_popup:bool = false

@onready var manager = get_parent()

@onready var initial = $ALL/Initial
@onready var advanced = $ALL/Advanced
@onready var host = $ALL/Host
@onready var join = $ALL/Join
@onready var quiz = $ALL/Quiz
@onready var deck = $ALL/deck_builder
@onready var profile = $ALL/Profile

@onready var animation = $animation
@onready var camera = $camera

var key_pressed:bool = false


func make_popup(error_code:String = ""):
	if !in_popup:
		var popup = popup_scene.instantiate()
		#popup.position = Vector2(671, 359)
		popup.error_code = error_code
		add_child(popup)
		if current_screen != INITIAL:
			_switch_screen(INITIAL)
		in_popup = true
		
		await popup.tree_exited
		in_popup = false

func _ready():
	for button in initial_buttons:
		button.mouse_entered.connect(_on_button_entered.bind(button))
		button.mouse_exited.connect(_on_button_exited.bind(button))
		button.focus_entered.connect(_on_button_focused.bind(button))
		%UPNP.button_pressed = Saves.battle_settings["UPNP"]
		%DayNight.button_pressed = Saves.battle_settings["DayNight"]
		%Food.button_pressed = Saves.battle_settings["Censor Food"]
	
	if Overworld.is_time_between(12 + 6, 0, 5, 0):
		$ambience.stream = load("res://minigames/raheem_battle/music/night-ambience.ogg")
		$ambience.play()
	
	$DayNightCycle.visible = true
	%Host.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		if !in_popup:
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
				PROFILE:
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
				PROFILE:
					animation.play('profile-initial')
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
		PROFILE:
			animation.play('initial-profile')
	if screen != INITIAL:
		for button in initial_buttons:
			button.disabled = true
			button.set_focus_mode(Control.FocusMode.FOCUS_NONE)
	else:
		for button in initial_buttons:
			button.disabled = false
			button.set_focus_mode(Control.FocusMode.FOCUS_ALL)
		%Host.grab_focus()
	current_screen = screen
	$paper_flip.play()
	
	if screen == QUIZ:
		await animation.animation_finished
		camera.can_scroll = true
	else:
		camera.can_scroll = false

func _on_button_entered(button):
	if button.get_focus_mode() == Control.FocusMode.FOCUS_ALL:
		button.grab_focus()

func _on_button_exited(_button):
	#$Pointer.visible = false
	pass

func _on_button_focused(button):
	#print('focused')
	$Pointer.visible = true
	$Pointer.global_position = button.global_position
	$Pointer.global_position.x -= 20
	$Pointer.global_position.y += button.size.y / 2

func _on_host_pressed():
	if !in_popup:
		_switch_screen(HOST)
func _on_join_pressed():
	if !in_popup:
		_switch_screen(JOIN)
func _on_advanced_pressed():
	if !in_popup:
		_switch_screen(ADVANCED)
func _on_quiz_pressed():
	if !in_popup:
		_switch_screen(QUIZ)
func _on_deck_pressed():
	if !in_popup:
		_switch_screen(DECK)
func _on_profile_pressed():
	if !in_popup:
		_switch_screen(PROFILE)


func _on_join_room_pressed():
	if check_playability() == false:
		make_popup("004")
		return
	if !Saves.battle_settings["UPNP"]:
		manager.on_join_pressed("localhost")
	elif %address_bar.text != "":
		manager.on_join_pressed(%address_bar.text)
func _on_create_room_pressed():
	if check_playability() == false:
		make_popup("004")
		return
	manager.on_host_pressed()

func check_playability() -> bool:
	for card in Saves.battle_deck.values():
		if card == "-1":
			return false
	return true

 
func _on_day_night_toggled(toggled_on: bool) -> void:
	Saves.battle_settings["DayNight"] = toggled_on
	Saves.save(Saves.SaveTypes.BATTLE)


func _on_upnp_toggled(toggled_on: bool) -> void:
	Saves.battle_settings["UPNP"] = toggled_on
	Saves.save(Saves.SaveTypes.BATTLE)

func _on_food_toggled(toggled_on: bool) -> void:
	Saves.battle_settings["Censor Food"] = toggled_on
	Saves.save(Saves.SaveTypes.BATTLE)
	
	for card in deck.get_node("ScrollContainer/card_container").get_children():
		card._on_stats_changed()


func _on_ambience_finished() -> void:
	$ambience.play()
