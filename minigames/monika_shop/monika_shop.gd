extends Node2D

@onready var idle_timer =  $idle_timer
@onready var balance = %balance

@onready var pages = [$Mice, $"Card Packs"]
var cur_index = 0


func _ready():
	DialogicUtil.autoload().Text.about_to_show_text.connect(_on_text_started)
	Dialogic.Inputs.auto_advance.enabled_forced = true
	Dialogic.start("res://minigames/monika_shop/dialogue/timeline.dtl")
	
	
	for page in pages:
		for item in page.get_children():
			item.hovered.connect(_on_item_hovered.bind(item))
			item.pressed.connect(_on_item_pressed.bind(item))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right"):
		change_page(1)

func change_page(displacement:int = 0):
	cur_index += displacement
	while cur_index >= pages.size():
		cur_index -= pages.size()
	for i in range(pages.size()):
		if i == cur_index:
			pages[i].visible = true
		else:
			pages[i].visible = false

func _on_item_hovered(item):
	idle_timer.wait_time = 30
	
	
	var cur_balance = Saves.get_coins()
	var after_balance = Saves.get_coins() - item.price
	balance.text = str(cur_balance) + " > " + str(after_balance)
	if after_balance < 0:
		balance.modulate = Color.RED
	else:
		balance.modulate = Color.WHITE

func _on_item_pressed(item):
	for page in pages:
		for shop_item in page.get_children():
			if shop_item != item:
				shop_item.current_state = shop_item.States.SALE


func _on_idle_timer_timeout() -> void:
	pass # Replace with function body.

func _on_text_started(_info):
	await get_tree().process_frame
	DialogicUtil.autoload().Inputs.auto_advance.override_delay_for_current_event = 1
