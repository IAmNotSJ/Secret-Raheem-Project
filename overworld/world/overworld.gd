extends Node

var positions:Dictionary = {
	"Main World" : Vector2(0, 0),
	"Key House" : Vector2(0, 0),
	"Apartment" : Vector2(0, 0),
	"Pizzeria" : Vector2(0, 0),
}

func save_position(position):
	positions["Main World"] = position
