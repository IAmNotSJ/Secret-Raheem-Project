@tool
extends Control

signal hovered()
signal pressed()

enum States {
	SALE,
	CONFIRM,
	BOUGHT
}

@onready var icon_tex = $icon
@onready var price_label = $Price
@onready var decay_timer = $decay_timer

@export var icon:CompressedTexture2D : 
	set(value):
		icon = value
		if icon_tex != null:
			icon_tex.texture = icon
@export var price:int = 100 : 
	set(value):
		price = value
		$Price.text = str(price) + " Coins"
# MAKE SURE TO INCLUDE MONIKA'S TITLE
@export var message:Array[String] = []

var current_state:States = States.SALE :
	set(value):
		current_state = value
		_on_current_state_changed(current_state)




func _ready():
	icon_tex.texture = icon
	price_label.text = str(price) + " Coins"
	
	decay_timer.timeout.connect(_on_current_state_changed.bind(current_state))

func _on_mouse_entered():
	icon_tex.position.y = -10
	hovered.emit()
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = message
	Dialogic.start(timeline)

func _on_mouse_exited():
	icon_tex.position.y = 0


func _on_click_detection_pressed() -> void:
	pressed.emit()
	match current_state:
		States.SALE:
			if Saves.can_remove_coins(price):
				current_state = States.CONFIRM
			else:
				decay_timer.start()
				price_label.text = "Too Expensive!"
		States.CONFIRM:
			if Saves.can_remove_coins(price):
				Saves.remove_coins(price)
				current_state = States.BOUGHT
				hovered.emit()
			else:
				current_state = States.SALE
				decay_timer.start()
				price_label.text = "Too Expensive!"
				

func _on_current_state_changed(state):
	match state:
		States.SALE:
			price_label.text = str(price) + " Coins"
		States.CONFIRM:
			price_label.text = "Confirm?"
		States.BOUGHT:
			price_label.text = "Sold Out!"

func change_state():
	pass
