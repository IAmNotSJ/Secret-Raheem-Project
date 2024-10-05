extends Node2D

const draggable_card = preload("res://minigames/raheem_battle/menu/deck_builder/draggable_card/draggable_card.tscn")
const normal_card = preload("res://minigames/raheem_battle/cards/card.tscn")
var held_card : DraggableCard

var is_in_preview:bool = false

var cards_removed:Array = []

func _ready():
	_create_cards()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		await get_tree().process_frame
		$dark.visible = false
		for child in $CenterContainer.get_children():
			child.queue_free()
		is_in_preview = false
# lord have mercy upon my wretched soul
func _create_cards():
	
	var every_card:Array = []
	while every_card.size() <= 156:
		var numbString = str(every_card.size())
		if numbString.length() == 1:
			numbString = "00" + numbString
		if numbString.length() == 2:
			numbString = "0" + numbString
		
		every_card.append(numbString)
	
	#print(every_card)
	for num in every_card:
		var card = draggable_card.instantiate()
		var file_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + num + ".tres"
		if FileAccess.file_exists(file_path):
			card.stats = load(file_path)
		%card_container.add_child(card)
		
		for i in Saves.battle_deck.keys().size():
			var card_num = Saves.battle_deck["Card " + str(i + 1)]
			if num == card_num:
				print(num + " has found a match")
				for snap in $snap_grid.get_children():
					if snap.deck_index == i + 1:
						snap.lock_card(card)
		

func set_held(card):
	if !is_in_preview:
		if held_card == null:
			held_card = card
			held_card.z_index = 1
			
			print('held set')

func clear_held():
	if held_card != null:
		held_card.z_index = 0
		held_card.let_go.emit()
		
		held_card = null
	

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("click"):
		clear_held()
	if held_card != null:
		#print(held_card.size)
		held_card.global_position.x = get_global_mouse_position().x - held_card.size.x / 2
		held_card.global_position.y = get_global_mouse_position().y - held_card.size.y / 2

func generate_preview(num):
	if !is_in_preview:
		$dark.visible = true
		var card = normal_card.instantiate()
		var file_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + num + ".tres"
		if FileAccess.file_exists(file_path):
			card.stats = load(file_path)
		card.is_preview = true
		is_in_preview = true
		card.get_node("visible").scale = Vector2(1, 1)
		card.set_custom_minimum_size(Vector2(397, 584)) 
		$CenterContainer.add_child(card)


func _on_save_pressed() -> void:
	Saves.save(Saves.SaveTypes.BATTLE)

func add_blank(daPos):
	var blank = Control.new()
	blank.size = Vector2(149, 216)
	blank.position = daPos
	%card_container.add_child(blank)
