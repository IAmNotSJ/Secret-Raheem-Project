extends TextureButton

@onready var hyena_clicker = get_parent().get_parent()
@onready var card_menu = get_parent()

var price:Big


var prices = [
	"3e4",
	"1e8",
	"4e13",
	"7.77e17",
	"8.8e20",
	"9.99e23",
	"1e25",
	"2e26",
	"1e27",
	"1e28",
	"1e29",
	"1e30"
]

func _ready():
	
	_update_price()


func _buy():
	if hyena_clicker.hyenas.isLargerThanOrEqualTo(price):
		hyena_clicker.hyenas.minus(price)
		card_menu.cur_upgrade += 1
		Saves.battle_stats["Hyena Upgrades"] += 1
		Saves.save(Saves.SaveTypes.BATTLE)
		
		card_menu.generate_card()
		_update_price()
		
		$kaching.play()
		card_menu.flash_player.play('flash')

func _update_price():
	await get_tree().process_frame
	if card_menu.cur_upgrade <= 11:
		price = Big.new(prices[card_menu.cur_upgrade])
		print(price.toString())
		print(card_menu.cur_upgrade)
		var shortNum
		if price.isLargerThanOrEqualTo(1000):
			shortNum = price.toPrefix()
			if shortNum.ends_with("000"):
				shortNum = shortNum.left(-3)
			elif shortNum.ends_with("00"):
				shortNum = shortNum.left(-2)
			elif shortNum.ends_with("0"):
				shortNum = shortNum.left(-1)
			if shortNum.ends_with("."):
				shortNum = shortNum.left(-1)
			shortNum = shortNum + price.getMetricSymbol()
		else:
			shortNum = price.toString()
		$price_label.text = "x" + shortNum
	else:
		$price_label.text = "MAX!"

func _on_pressed():
	if card_menu.cur_upgrade <= 11:
		if !card_menu.flash_player.is_playing():
			_buy()
