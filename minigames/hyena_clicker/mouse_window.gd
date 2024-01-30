extends Sprite2D

@onready var title = $Title
@onready var description = $Description
@onready var price = $Price

var rightOfMouse:bool = true

var curLine = 0

func _process(_delta):
	if rightOfMouse:
		global_position = get_global_mouse_position() + Vector2(50, 50)
	else:
		global_position = get_global_mouse_position() + Vector2(-230, 50)
	
	if global_position.y > 420:
		global_position.y = 420
	if global_position.x > 1043:
		global_position.x = 1043
func _unhandled_input(_event):
	if visible:
		if Input.is_action_just_pressed("scroll_down"):
			curLine -= 1
			description.scroll_to_line(curLine)
		if Input.is_action_just_pressed("scroll_up"):
			curLine += 1
			description.scroll_to_line(curLine)

func set_text(daTitle:String = 'NULL', daDescription:String = 'NULL', daPrice:String = 'NULL', disabled:bool = false):
	if daTitle == "HYENA MULTILEVEL QUANTUM MANIPULATOR":
		daTitle = "HYENA M.Q.N."
	title.text = "[b]" + daTitle + "[/b]"
	description.text = daDescription
	if daPrice != 'NULL' and !disabled:
		price.text = daPrice.to_upper() + " HYENAS"
	else:
		price.text = " "
