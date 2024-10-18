extends Node2D

const gamePath = preload("res://minigames/raheem_battle/game/raheem_battle.tscn")
var game
const menuPath = preload("res://minigames/raheem_battle/menu/menu.tscn")
var menu
@onready var current_scene = $Menu

var multiplayer_peer = ENetMultiplayerPeer.new()

const PORT = 7890

#Array of all the peer ids connected to the server. Will be a STRING
var connected_peer_ids = []

enum {
	SERVER,
	CLIENT
}
var game_type :
	set(value):
		match value:
			SERVER:
				%game_type.text = "GameType: Server"
			CLIENT:
				%game_type.text = "GameType: Client"
		game_type = value
var peer_id:int  = -1:
	set(value) :
		peer_id = value
		%peer_id.text = "PeerID: " + str(peer_id)
var room_address :	
	set(value) :
		room_address = value
		%room_address.text = "RoomAddress: " + room_address

func _ready():
	game = gamePath.instantiate()

func _unhandled_input(event):
	if event.is_action_pressed("F3"):
		if $NetworkInfo.visible == true:
			$NetworkInfo.visible = false
		else:
			$NetworkInfo.visible = true
	if event.is_action_pressed("hyena"):
		_disconnect()

func return_to_menu(error_code:String):
	make_menu()
	menu.make_popup(error_code)
	current_scene.queue_free()
	current_scene = menu

func make_game():
	game = gamePath.instantiate()
	add_child(game)

func make_menu():
	menu = menuPath.instantiate()
	add_child(menu)



# # # # NETWORKING STUFF # # # #

# ----Join commands---- #
@rpc
func add_player(daPeer):
	connected_peer_ids.append(daPeer)
	var player_name = Saves.battle_info["Name"]
	print("PLAYER NAME: " + player_name)
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
	make_game()
	
	# Ima keep it a buck fifty with you i have no clue why I need to do it like this, but it works
	# replacing multiplayer_peer with multiplayer.multiplayer_peer messes everythinnnggg up
	multiplayer_peer = ENetMultiplayerPeer.new()
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	var address
	if current_scene.upnp:
		address = upnp_setup()
	else:
		address = "localhost"
	
	game_type = SERVER
	peer_id = multiplayer.get_unique_id()
	room_address = str(address)
	
	#Adds the PLAYER for the host
	add_player(peer_id)
	
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			#Adds the PLAYER for the client that just connected
			add_player.rpc(new_peer_id)
			#Adds the OPPONENT for the client that just connected
			add_opponent.rpc(multiplayer.multiplayer_peer.get_unique_id(), Saves.battle_info)
			
			# Just to give the client enough time to actually join.
			# TODO: Find a better way to do this. Perhaps with a signal that is emitted by the player character when they join the game? idk 
			await get_tree().create_timer(1).timeout
			game.start_game_request()
	)
	if !multiplayer_peer.is_connected("peer_disconnected", _on_peer_disconnect):
		multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	
	current_scene.queue_free()
	current_scene = game

func on_join_pressed(ADDRESS):
	make_game()
	if ADDRESS == "localhost":
		multiplayer_peer.create_client(ADDRESS, PORT)
	else:
		multiplayer_peer.create_client(decrypt_address(ADDRESS), PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.connected_to_server.connect(
		func():
			add_opponent.rpc(multiplayer.multiplayer_peer.get_unique_id(), Saves.battle_info)
	)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	
	game_type = CLIENT
	peer_id = multiplayer.get_unique_id()
	room_address = str(ADDRESS)
	
	current_scene.queue_free()
	current_scene = game

#Internet stuff
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	upnp.add_port_mapping(PORT, 0, "godot_udp", "UDP", 0)
	var map_result_tcp = upnp.add_port_mapping(PORT, 0, "godot_tcp", "TCP", 0)
	assert(map_result_tcp == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result_tcp)
	
	var daAddress = encrypt_address(upnp.query_external_address())
	
	print("Success! Join Address: %s" % daAddress)
	
	return(daAddress)

func _disconnect():
	if peer_id != -1:
		print('disconnecting!')
		multiplayer_peer.close()
	return_to_menu("-1")

func _on_peer_disconnect(id):
	print("PLAYER WITH ID " + str(id) + " DISCONNECTED")
	return_to_menu("0")

func encrypt_address(address):
	var address_array = address.split(".")
	
	var encrypted_address_array:Array = []
	
	for i in range(address_array.size()):
		var number = int(address_array[i])
		encrypted_address_array.append(str(number))
	
	
	var encrypted_address:String = ".".join(encrypted_address_array)
	return encrypted_address
func decrypt_address(address):
	var address_array = address.split(".")
	var encrypted_address_array:Array = []
	
	for i in range(address_array.size()):
		var number = int(address_array[i])
		encrypted_address_array.append(str(number))
	
	
	var encrypted_address:String = ".".join(encrypted_address_array)
	return encrypted_address
