extends Control

@onready var ui = get_parent()
@onready var text_box = %text_box

@onready var scroll_c = %scroll_container
@onready var scroll_b = scroll_c.get_v_scroll_bar()

const chat_message_scene = preload("res://minigames/raheem_battle/chat/message/chat_message.tscn")

var collapsed:bool = false

var chat_log:Array[String] = []


func _on_input_text_submitted(new_text):
	var can_send:bool = false
	for chr in new_text:
		if chr != "" and chr != " ":
			can_send = true
	if can_send:
		add_new_message(new_text, ui.game.get_player().player_name)
		add_sent_message.rpc(new_text, ui.game.get_player().player_name)
		%input.clear()


func add_new_message(message, player_name):
	if collapsed:
		_on_hide_button_pressed()
	var new_message = chat_message_scene.instantiate()
	new_message.text = player_name + ": " + message
	new_message.sender = player_name
	text_box.add_child(new_message)
	
	chat_log.push_front(new_message.text)
	
	await get_tree().process_frame
	await get_tree().process_frame 
	scroll_c.scroll_vertical = scroll_b.max_value

@rpc("any_peer")
func add_sent_message(message, player_name):
	add_new_message(message, player_name)


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
