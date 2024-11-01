class_name Player
extends Node

#Mirror enum of the Sides enum in game. 
enum Sides {
	ATTACKING,
	DEFENDING,
	TIE
}
@onready var game = get_parent().get_parent().get_parent()

var player_name:String
var player_color:Color
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
					game.ui.turn_info.side.text = "Attacking"
					game.ui.turn_info.bop()
				Sides.DEFENDING:
					game.ui.turn_info.side.text = "Defending"
					game.ui.turn_info.bop()


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
