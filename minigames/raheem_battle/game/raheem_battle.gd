extends Node2D

signal game_started

@onready var manager = get_parent()
@onready var players = %players

@onready var turn_decider = %turn_decider

enum Sides {
	ATTACKING,
	DEFENDING,
	TIE
}

# First player is the one who loads this scene
var players_joined:int = 1

var playing_peer_ids:Array = []

var ui_path = preload("res://minigames/raheem_battle/ui/ui.tscn")
var ui

var player_path = preload("res://minigames/raheem_battle/player/player.tscn")
var opponent_path = preload("res://minigames/raheem_battle/opponents/opponent.tscn")

var started:bool = false
var turn_count:int = 0 :
	set(value):
		turn_count = value
		manager.get_node("NetworkInfo/turn_count").text = "TurnCount: " + str(turn_count)

var last_decision:Sides

var pixel_size:float = 1 :
	set(value) :
		pixel_size = value
		if pixel_size > 1:
			$Pixelate.visible = true
		else:
			$Pixelate.visible = false

var glitch_timer:int = 0

func _process(delta):
	var dapixel:float = $Pixelate.get("material").get("shader_parameter/pixel_size")
	dapixel = lerpf(dapixel, pixel_size, delta)
	$Pixelate.get("material").set("shader_parameter/pixel_size", dapixel)

func add_player(player_name, peer_id):
	playing_peer_ids.append(peer_id)
	
	#Add the player Node
	var player = player_path.instantiate()
	player.player_name = player_name
	player.name = str(peer_id)
	player.is_player = true
	players_joined += 1
	players.add_child(player)
	
	#Add the UI for the player
	var daUI = ui_path.instantiate()
	add_child(daUI)
	
	var deck = Saves.battle_deck.values()
	daUI.card_hand.generate_cards(deck)
	ui = daUI
func add_opponent(opponent_id, opponent_name):
	playing_peer_ids.append(opponent_id)
	
	#Add the second player Node
	
	var player = player_path.instantiate()
	player.player_name = opponent_name
	player.is_player = false
	player.name = str(opponent_id)
	players_joined += 1
	players.add_child(player)
	
	#Add the opponent graphic
	var opponent = opponent_path.instantiate()
	%opponent_position.add_child(opponent)

#Returns the player node that is currently linked to the PLAYER
func get_player():
	for player in players.get_children():
		if player.name == str(multiplayer.multiplayer_peer.get_unique_id()):
			return player
#Returns the player node that is currently linked to the OPPONENT
func get_opponent():
	for player in players.get_children():
		if player.name != str(multiplayer.multiplayer_peer.get_unique_id()):
			return player

# Sends a REQUEST to start the game. Essentially used to do the random calculation for the side
# that each person will be assigned. Once that calc is complete, the actual start_game function 
# will be called, assigning that side to each player
func start_game_request():
	var rng = RandomNumberGenerator.new()
	if playing_peer_ids.size() == 2:
		if rng.randi_range(0, 1) == 0:
			start_game(Sides.ATTACKING)
			start_game.rpc(Sides.DEFENDING)
		else:
			start_game(Sides.DEFENDING)
			start_game.rpc(Sides.ATTACKING)
	else:
		print("Playing Peer IDs are wrong! The actual size is: " + str(playing_peer_ids.size()))
		print("Playing Peer IDs: " + str(playing_peer_ids))
#Starts the game and assigns either attacking or defending to the two connected peer IDs
@rpc()
func start_game(side:Sides):
	print('game has started!')
	
	started = true
	match side:
		Sides.ATTACKING:
			get_player().side = Sides.ATTACKING
			get_opponent().side = Sides.DEFENDING
		Sides.DEFENDING:
			get_player().side = Sides.DEFENDING
			get_opponent().side = Sides.ATTACKING
	
	ui.start_turn()
	
	game_started.emit()
