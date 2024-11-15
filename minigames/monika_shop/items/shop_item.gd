@tool
extends Control

@onready var icon_tex = $icon

@export var icon:CompressedTexture2D : 
	set(value):
		icon = value
		if icon_tex != null:
			icon_tex.texture = icon
@export var price:float = 100 : 
	set(value):
		price = value
		$Price.text = str(price) + "Coins"

# MAKE SURE TO INCLUDE MONIKA'S TITLE
@export var message:Array[String] = []

func _ready():
	icon_tex.texture = icon
	$Price.text = str(price) + " Coins"

func _on_mouse_entered():
	icon_tex.position.y = -10
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = message
	Dialogic.start(timeline)

func _on_mouse_exited():
	icon_tex.position.y = 0
