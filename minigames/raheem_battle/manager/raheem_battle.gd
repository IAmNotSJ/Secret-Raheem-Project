extends Node2D

signal game_made
signal player_joined(id)

const gamePath = preload("res://minigames/raheem_battle/game/raheem_battle.tscn")
var game = null
const menuPath = preload("res://minigames/raheem_battle/menu/menu.tscn")
var menu
@onready var current_scene = $Menu

var multiplayer_peer = ENetMultiplayerPeer.new()

var waiting_to_join:bool = false

const PORT = 215

#Array of all the peer ids connected to the server. Will be a STRING
var connected_peer_ids = []

enum {
	SERVER,
	CLIENT
}
var game_type
var peer_id:int  = -1
var room_address : 
	set(value):
		room_address = value
		if game != null:
			game.ui.turn_info.set_address(room_address)

var match_rules:Dictionary = {
	"Deck Size" : "8 Cards",
	"Cards To Win": 2,
}

func _ready():
	match_rules = Saves.battle_rules

func _unhandled_input(event):
	if event.is_action_pressed("hyena"):
		disconnect_from_game()

func return_to_menu(error_code:String = "-1"):
	var send_error:bool = true
	make_menu()
	
	if error_code == "":
		send_error = false
	
	if send_error:
		menu.make_popup(error_code)
	current_scene.queue_free()
	current_scene = menu

func make_game():
	game = gamePath.instantiate()
	add_child(game)
	game_made.emit()

func make_menu():
	menu = menuPath.instantiate()
	add_child(menu)



# # # # NETWORKING STUFF # # # #

# ----Join commands---- #
@rpc
func add_player(daPeer):
	connected_peer_ids.append(daPeer)
	var player_name = Saves.battle_info["Name"]
	if player_name == "":
		player_name = "Random Player"
	game.add_player(player_name, daPeer)
@rpc("any_peer")
func add_opponent(daPeer, opponent_info):
	var opponent_name = opponent_info["Name"]
	if opponent_name.is_empty:
		opponent_name = "Random Player"
	if opponent_name == Saves.battle_info["Name"]:
		opponent_name = opponent_name + " #2"
	connected_peer_ids.append(daPeer)
	game.add_opponent(daPeer, opponent_info)

# ---- Miscellaneous ---- #

func on_host_pressed():
	
	# Ima keep it a buck fifty with you i have no clue why I need to do it like this, but it works
	# replacing multiplayer_peer with multiplayer.multiplayer_peer messes everythinnnggg up
	close_peer()
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	var address
	if Saves.battle_settings["UPNP"]:
		address = upnp_setup()
		if address == "-1":
			return
	else:
		address = "localhost"
	
	make_game()
	
	game_type = SERVER
	peer_id = multiplayer.get_unique_id()
	room_address = str(address)
	game.match_rules = match_rules
	
	#Adds the PLAYER for the host
	add_player(peer_id)
	
	#Disconnect the player_joined code
	if player_joined.is_connected(_on_player_joined):
		player_joined.disconnect(_on_player_joined)
	player_joined.connect(_on_player_joined)
	
	#Disconnect the peer_disconnected code
	if multiplayer.multiplayer_peer.peer_disconnected.is_connected(_on_peer_disconnect):
		multiplayer.multiplayer_peer.peer_disconnected.disconnect(_on_peer_disconnect)
	multiplayer.multiplayer_peer.peer_disconnected.connect(_on_peer_disconnect)
	
	current_scene.queue_free()
	current_scene = game

func _on_player_joined(new_peer_id):
	#Adds the PLAYER for the client that just connected
	add_player.rpc(new_peer_id)
	#Adds the OPPONENT for the client that just connected
	add_opponent.rpc(multiplayer.multiplayer_peer.get_unique_id(), Saves.battle_info)
	
	# Just to give the client enough time to actually join.
	# TODO: Find a better way to do this. Perhaps with a signal that is emitted by the player character when they join the game? idk 
	await get_tree().create_timer(1).timeout
	if game != null:
		game.start_game_request()

func on_join_pressed(ADDRESS):
	multiplayer_peer = ENetMultiplayerPeer.new()
	if ADDRESS == "localhost":
		multiplayer_peer.create_client(ADDRESS, PORT)
	else:
		multiplayer_peer.create_client(Encryption.decrypt_address(ADDRESS), PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	if multiplayer.connected_to_server.is_connected(_on_join_connected):
		multiplayer.connected_to_server.disconnect(_on_join_connected)
	multiplayer.connected_to_server.connect(_on_join_connected.bind(ADDRESS))
	
	waiting_to_join = true
	await get_tree().create_timer(5).timeout
	if waiting_to_join:
		waiting_to_join = false
		print("FAIL!")
		multiplayer.connected_to_server.disconnect(_on_join_connected)
		current_scene.make_popup("006")

func _on_join_connected(ADDRESS):
	var id = multiplayer.get_unique_id()
	var data:Dictionary = {
		"Address" : ADDRESS,
		"Game Version" : ProjectSettings.get_setting("application/config/version"),
		"Deck" : Saves.battle_deck
	}
	_receive_join_request.rpc(id, data)

@rpc("any_peer")
func _receive_join_request(id, data):
	# Can't be lower than one (room isnt open) and can't be greater than one (room is full)
	if data["Game Version"] == ProjectSettings.get_setting("application/config/version"):
		if connected_peer_ids.size() != 1:
			#BAD
			close_peer.rpc_id(id)
			current_scene.make_popup.rpc_id(id, "005")
		else:
			var can_join:bool = true
			for card in data["Deck"][match_rules["Deck Size"]]:
				if card == "-1":
					can_join = false
			if can_join:
				#GOOD
				var host_data:Dictionary = {
					"Address" : data["Address"],
					"Game Version" : ProjectSettings.get_setting("application/config/version"),
					"Match Rules" : match_rules
				}
				join_game.rpc_id(id, host_data)
			else:
				var num_string = match_rules["Deck Size"].replace(" Cards", "")
				close_peer.rpc_id(id)
				menu.make_popup.rpc_id(id, "004-" + num_string)
	else:
		close_peer.rpc_id(id)
		current_scene.make_popup.rpc_id(id, "007")

@rpc("authority")
func join_game(data):
	if waiting_to_join:
		if multiplayer.multiplayer_peer.peer_disconnected.is_connected(_on_peer_disconnect):
			multiplayer.multiplayer_peer.peer_disconnected.disconnect(_on_peer_disconnect)
		multiplayer.multiplayer_peer.peer_disconnected.connect(_on_peer_disconnect)
		make_game()
		
		waiting_to_join = false
		
		add_opponent.rpc(multiplayer.multiplayer_peer.get_unique_id(), Saves.battle_info)
		
		peer_id = multiplayer.get_unique_id()
		game_type = CLIENT
		room_address = str(data["Address"])
		
		current_scene.queue_free()
		current_scene = game
		
		game.match_rules = data["Match Rules"]
		
		send_join_notification.rpc_id(1, peer_id)

@rpc("any_peer")
func send_join_notification(id):
	player_joined.emit(id)

#Internet stuff
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		current_scene.make_popup("008")
		return "-1"

	if !upnp.get_gateway() || !upnp.get_gateway().is_valid_gateway():
		current_scene.make_popup("009")
		return "-1"

	upnp.add_port_mapping(PORT, 0, "godot_udp", "UDP", 0)
	var map_result_tcp = upnp.add_port_mapping(PORT, 0, "godot_tcp", "TCP", 0)
	assert(map_result_tcp == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result_tcp)
	
	var daAddress = Encryption.encrypt_address(upnp.query_external_address())
	
	print("Success! Join Address: %s" % daAddress)
	
	return(daAddress)

@rpc("any_peer")
func disconnect_from_game(code:String = ""):
	if peer_id != -1:
		print('disconnecting!')
		close_peer()
	return_to_menu(code)

@rpc("any_peer")
func close_peer():
	multiplayer_peer.close()
	connected_peer_ids = []
#Used to DISCRETELY disconnect. Will not trigger opponent to disconnect either
@rpc("any_peer")
func disconnect_discrete():
	clear_peer_ids.rpc()
	multiplayer_peer.close()

@rpc("any_peer")
func clear_peer_ids():
	connected_peer_ids = []

func _on_peer_disconnect(id):
	if connected_peer_ids.find(id) != -1:
		print("PLAYER WITH ID " + str(id) + " DISCONNECTED")
		disconnect_from_game("0")
