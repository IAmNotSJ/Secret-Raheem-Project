extends Node

#Mirror enum of the Sides enum in game. 
enum Sides {
	ATTACKING,
	DEFENDING,
	TIE
}
@onready var game = get_parent().get_parent()

var player_name:String
var is_player:bool = false

var cards_left

var turn_history:Dictionary = {
	"First Card" : {}
}

var side:Sides :
	set(value):
		side = value
		if is_player:
			match side:
				Sides.ATTACKING:
					game.manager.get_node("NetworkInfo/side").text = "Side: Attacking"
				Sides.DEFENDING:
					game.manager.get_node("NetworkInfo/side").text = "Side: Defending"

var locked_in:bool = false

func lock():
	locked_in = true

func unlock():
	locked_in = false

func switch_side():
	if side == Sides.ATTACKING:
		side = Sides.DEFENDING
	elif side == Sides.DEFENDING:
		side = Sides.ATTACKING
