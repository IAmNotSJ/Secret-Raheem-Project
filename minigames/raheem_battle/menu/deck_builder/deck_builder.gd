extends Node2D

const draggable_card = preload("res://minigames/raheem_battle/menu/deck_builder/draggable_card/draggable_card.tscn")
const normal_card = preload("res://minigames/raheem_battle/cards/card.tscn")
var held_card : DraggableCard

var is_in_preview:bool = false

var cards_removed:Array = []
var every_card:Array = []
var cards:Array = []

func _ready():
	_create_cards()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		await get_tree().process_frame
		$dark.visible = false
		is_in_preview = false
		for child in $CenterContainer.get_children():
			child.queue_free()
# lord have mercy upon my wretched soul
func _create_cards():
	
	var card_count:int = 0
	for i in range(156):
		var numbString = str(card_count)
		if numbString.length() == 1:
			numbString = "00" + numbString
		if numbString.length() == 2:
			numbString = "0" + numbString
		
		if Saves.battle_unlocks[numbString] == 1:
			every_card.append(numbString)
		card_count += 1
	
	for num in every_card:
			var file_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + num + ".tres"
			if FileAccess.file_exists(file_path):
				var card = draggable_card.instantiate()
				card.stats = load(file_path)
				card.let_go.connect(_on_held_card_let_go)
				card.taken_out.connect(_on_held_card_let_go)
				%card_container.add_child(card)
				cards.append(card)
				
				for i in Saves.battle_deck.keys().size():
					var card_num = Saves.battle_deck["Card " + str(i + 1)]
					if num == card_num:
						for snap in $snap_container.get_children():
							if snap.deck_index == i + 1:
								snap.lock_card(card)
	_on_held_card_let_go()

func set_held(card):
	if !is_in_preview:
		if held_card == null:
			held_card = card
			held_card.z_index = 1

func clear_held():
	if held_card != null:
		held_card.z_index = 0
		held_card.let_go.emit()
		
		held_card = null

func _on_held_card_let_go():
	var row = 0
	for card in cards:
		var pos = int(card.stats.card_number)
		if pos % 3 == 0:
			row += 1
		if card.snap == null:
			card.position.x = (20 + card.size.x) * (pos % 3)
			card.position.y = (18 + card.size.y) * (row - 1)

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
			card.stats = card.return_stats_from_resource(file_path)
		card.is_preview = true
		is_in_preview = true
		card.get_node("visible").scale = Vector2(1, 1)
		card.set_custom_minimum_size(Vector2(397, 584)) 
		$CenterContainer.visible = true
		$CenterContainer.add_child(card)


func _on_save_pressed() -> void:
	Saves.save(Saves.SaveTypes.BATTLE)
func _on_clear_pressed() -> void:
	for snap in $snap_container.get_children():
		if snap.card != null:
			snap.card.clear_snap()
	_on_held_card_let_go()

func add_blank(daPos):
	var blank = Control.new()
	blank.size = Vector2(149, 216)
	blank.position = daPos
	%card_container.add_child(blank)
