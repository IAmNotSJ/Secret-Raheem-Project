extends Control

@onready var ui = get_parent()
@onready var text_box = %text_box

@onready var scroll_c = %scroll_container
@onready var scroll_b = scroll_c.get_v_scroll_bar()

const chat_message_scene = preload("res://minigames/raheem_battle/chat/message/chat_message.tscn")

var collapsed:bool = false

var chat_log:Array[String] = []

var message_sent_in_turn:bool = false


func _on_input_text_submitted(new_text):
	var can_send:bool = false
	for chr in new_text:
		if chr != "" and chr != " ":
			can_send = true
	if can_send:
		add_new_message(new_text, ui.game.get_player().player_color, ui.game.get_player().player_name, "nvm")
		add_sent_message.rpc(new_text, ui.game.get_player().player_color, ui.game.get_player().player_name, %emotion_button.cur_emotion)
		%input.clear()


func add_new_message(message, message_color, player_name, player_emotion):
	message_sent_in_turn = true
	if collapsed:
		_on_hide_button_pressed()
	var new_message = chat_message_scene.instantiate()
	new_message.text = player_name + ": " + message
	new_message.sender = player_name
	new_message.add_theme_color_override("font_color", message_color)
	text_box.add_child(new_message)
	
	chat_log.push_front(new_message.text)
	
	if ui.game.opponent != null:
		ui.game.opponent.change_emotion(player_emotion)
	
	await get_tree().process_frame
	await get_tree().process_frame 
	scroll_c.scroll_vertical = scroll_b.max_value

@rpc("any_peer")
func add_sent_message(message, message_color, player_name, player_emotion):
	add_new_message(message, message_color, player_name, player_emotion)


func _on_send_button_pressed():
	_on_input_text_submitted(%input.text)


func _on_hide_button_pressed():
	var button = %hide_button
	
	if !collapsed:
		button.text = "V"
		$animation.play('hide')
		collapsed = true
	else:
		button.text = "^"
		$animation.play('show')
		collapsed = false
