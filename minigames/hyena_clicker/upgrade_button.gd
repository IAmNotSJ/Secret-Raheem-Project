extends TextureButton

@export var upgrade:String = ''
@export_multiline var description:String = ''

@export var price:String = '1'

@export var stage:int = 0
@export var line:String = ''

@export var texture:Texture2D

var bigPrice:Big

func _ready():
	bigPrice = Big.new(price)
	texture_normal = texture

func _process(delta):
	if get_tree().root.get_node("HyenaClicker").hyenas.isLessThan(bigPrice):
		modulate = Color("#919191")
	else:
		modulate = Color("#ffffff")

func _on_mouse_entered():
	get_tree().root.get_node("HyenaClicker").mouseWindow.visible = true
	get_tree().root.get_node("HyenaClicker").mouseWindow.set_text(upgrade, description, price)
	get_tree().root.get_node("HyenaClicker").mouseWindow.rightOfMouse = false

func _on_mouse_exited():
	get_tree().root.get_node("HyenaClicker").mouseWindow.visible = false
