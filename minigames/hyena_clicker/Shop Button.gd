class_name ShopButton extends TextureButton

signal clicked(button:ShopButton)

@export var price:int = 0
@export var price_multiplier:float = 1

@export var item:String = ''

var bigPrice : Big

func _ready():
	bigPrice = Big.new(price)
	$Title.text = item

func update_price():
	var shortNum
	if bigPrice.isLargerThanOrEqualTo(1000):
		shortNum = bigPrice.toPrefix()
		if shortNum.ends_with("000"):
			shortNum = shortNum.left(-4)
		elif shortNum.ends_with("00"):
			shortNum = shortNum.left(-2)
		elif shortNum.ends_with("0"):
			shortNum = shortNum.left(-1)
		shortNum = shortNum + bigPrice.getMetricSymbol()
	else:
		shortNum = bigPrice.toString()
	$PriceText.text = "x" + shortNum

func multiply_price(val):
	bigPrice.multiply(val)
	
	if bigPrice.toString().ends_with(".5"):
		bigPrice.minus(0.5)
	

func _on_pressed():
	clicked.emit(self)
