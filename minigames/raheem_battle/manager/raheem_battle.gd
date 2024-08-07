extends Node2D

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
var peer_id:int :
	set(value) :
		peer_id = value
		%peer_id.text = "PeerID: " + str(peer_id)
var room_address :	
	set(value) :
		room_address = value
		%room_address.text = "RoomAddress: " + room_address

func _unhandled_input(event):
	if event.is_action_pressed("F3"):
		if $NetworkInfo.visible == true:
			$NetworkInfo.visible = false
		else:
			$NetworkInfo.visible = true

#Scene manager
func switch_screen(daScreen:String):
	match daScreen:
		"Raheem Battle":
			$RaheemBattle.visible = true
			$Menu.visible = false

#Join commands
@rpc
func add_player(daPeer):
	connected_peer_ids.append(daPeer)
	$RaheemBattle.add_player($Menu.display_name, daPeer)
@rpc("any_peer")
func add_opponent(daPeer, display_name):
	connected_peer_ids.append(daPeer)
	$RaheemBattle.add_opponent(daPeer, display_name)

func on_host_pressed():
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	var address
	if $Menu.upnp:
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
			add_opponent.rpc(multiplayer.multiplayer_peer.get_unique_id(), $Menu.display_name)
			
			# Just to give the client enough time to actually join.
			# TODO: Find a better way to do this. Perhaps with a signal that is emitted by the player character when they join the game? idk 
			await get_tree().create_timer(1).timeout
			$RaheemBattle.start_game_request()
	)
	
	switch_screen("Raheem Battle")
func on_join_pressed(ADDRESS):
	if ADDRESS == "localhost":
		multiplayer_peer.create_client(ADDRESS, PORT)
	else:
		multiplayer_peer.create_client(decrypt_address(ADDRESS), PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.connected_to_server.connect(
		func():
			add_opponent.rpc(multiplayer.multiplayer_peer.get_unique_id(), $Menu.display_name)
	)
	
	game_type = CLIENT
	peer_id = multiplayer.get_unique_id()
	room_address = str(ADDRESS)
	
	switch_screen("Raheem Battle")

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
