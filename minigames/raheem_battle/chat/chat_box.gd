extends Control

@onready var ui = get_parent()
@onready var text_box = %text_box

const chat_message_scene = preload("res://minigames/raheem_battle/chat/message/chat_message.tscn")



func _on_input_text_submitted(new_text):
	add_new_message(new_text, ui.game.get_player().player_name)
	add_sent_message.rpc(new_text, ui.game.get_player().player_name)
	%input.clear()


func add_new_message(message, player_name):
	var new_message = chat_message_scene.instantiate()
	new_message.text = player_name + ": " + message
	new_message.sender = player_name
	text_box.add_child(new_message)

@rpc("any_peer")
func add_sent_message(message, player_name):
	add_new_message(message, player_name)
