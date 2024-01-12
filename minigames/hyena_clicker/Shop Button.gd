class_name ShopButton extends TextureButton

signal clicked(button:ShopButton)

@export var price:String = ''
@export var price_multiplier:float = 1

@export var item:String = ''

@export var limit:int = 0

@export_multiline var description:String = ''

var bigPrice : Big

func _ready():
	bigPrice = Big.new(price)
	if item.length() >= 20:
		$Title.add_theme_font_size_override("normal_font_size", 12)
	elif item.length() >= 12:
		$Title.add_theme_font_size_override("normal_font_size", 16)
	else:
		$Title.add_theme_font_size_override("normal", 20)
	$Title.text = item

func update_price():
	var shortNum
	if bigPrice.isLargerThanOrEqualTo(1000):
		shortNum = bigPrice.toPrefix()
		print(shortNum)
		if shortNum.ends_with("000"):
			shortNum = shortNum.left(-3)
		elif shortNum.ends_with("00"):
			shortNum = shortNum.left(-2)
		elif shortNum.ends_with("0"):
			shortNum = shortNum.left(-1)
		if shortNum.ends_with("."):
			shortNum = shortNum.left(-1)
		shortNum = shortNum + bigPrice.getMetricSymbol()
	else:
		shortNum = bigPrice.toString()
	$PriceText.text = "x" + shortNum

func multiply_price(val):
	bigPrice.multiply(val)
	
	if bigPrice.toString().ends_with(".5"):
		bigPrice.minus(0.5)

func disable():
	disabled = true
	modulate = Color(92, 92, 92)
	$PriceText.visible = false
	$Hyena.visible = false
	$Title.text = "Out of Stock!"

func _on_pressed():
	clicked.emit(self)


func _on_mouse_entered():
	get_tree().root.get_node("HyenaClicker").mouseWindow.visible = true
	get_tree().root.get_node("HyenaClicker").mouseWindow.set_text(item, description, bigPrice.toString(), disabled)
	get_tree().root.get_node("HyenaClicker").mouseWindow.rightOfMouse = true

func _on_mouse_exited():
	get_tree().root.get_node("HyenaClicker").mouseWindow.visible = false
