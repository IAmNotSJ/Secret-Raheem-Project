extends Node2D

const draggable_card = preload("res://minigames/raheem_battle/menu/deck_builder/draggable_card/draggable_card.tscn")
const normal_card = preload("res://minigames/raheem_battle/cards/card.tscn")
var held_card : DraggableCard

var is_in_preview:bool = false

var cards_removed:Array = []
var every_card:Array = []
var cards:Array = []

var cur_deck = "8 Cards"

@onready var decks = [%"8 Cards", %"9 Cards", %"10 Cards", %"11 Cards", %"12 Cards"]

func _ready():
	_create_cards()
	
	#for snap in $snap_container.get_children():
	#	snap.locked.connect(_on_card_locked)

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
			if ResourceLoader.exists(file_path):
				var card = draggable_card.instantiate()
				var stats = load(file_path)
				
				card.stats["Card Name"] = stats.card_name
				card.stats["Card Series"] = stats.card_series
				card.stats["Card Number"] = stats.card_number
				card.stats["Base Attack"] = stats.base_attack
				card.stats["Base Defense"] = stats.base_defense
				card.stats["Can Get Bonuses"] = stats.can_get_bonuses
				card.stats["Ability Name"] = stats.ability_name
				card.stats["Ability Description"] = stats.ability_description
				card.stats["One Use Ability"] = stats.one_use_ability
				card.stats["Should Remove"] = stats.should_remove
				card.stats["Hide Stats"] = stats.hide_stats
				card.stats["Is Human"] = stats.is_human
				card.stats["Has Hands"] = stats.has_hands
				card.let_go.connect(_on_held_card_let_go)
				card.taken_out.connect(_on_held_card_let_go)
				%card_container.add_child(card)
				cards.append(card)
				
				card._recalculate_attack()
				card._recalculate_defense()
				card._on_stats_changed()
	set_deck()
	_on_held_card_let_go()

func set_deck():
	_on_clear_pressed()
	
	var cards_number = []
	for card in cards:
		cards_number.append(card.stats["Card Number"])
	var deck_array = []
	for i in range(Saves.battle_deck[cur_deck].size()):
		if cards_number.find(Saves.battle_deck[cur_deck][i]) != -1:
			deck_array.append(cards[cards_number.find(Saves.battle_deck[cur_deck][i])])
		else:
			deck_array.append(null)
	var previous_cards = []
	for i in range(deck_array.size()):
		if deck_array[i] != null:
			if !previous_cards.has(deck_array[i]):
				$snap_container.get_node(cur_deck).get_children()[i].lock_card(deck_array[i])
			else:
				Saves.battle_deck[cur_deck][i] = "-1"
				#print(Saves.battle_deck[cur_deck][i])
			previous_cards.append(deck_array[i])

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
		var pos = int(card.stats["Card Number"])
		if pos % 3 == 0:
			row += 1
		if card.snap == null:
			var card_size = Vector2(149, 216)
			card.position.x = (20 + card_size.x) * (pos % 3)
			card.position.y = (18 + card_size.y) * (row - 1)
	$swipe.play()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("click"):
		clear_held()
	if held_card != null:
		held_card.global_position.x = get_global_mouse_position().x - held_card.size.x / 2
		held_card.global_position.y = get_global_mouse_position().y - held_card.size.y / 2

func generate_preview(num):
	if !is_in_preview:
		$dark.visible = true
		var card = normal_card.instantiate()
		var file_path = "res://minigames/raheem_battle/cards/card_variants/stats/" + num + ".tres"
		if ResourceLoader.exists(file_path):
			card.stats = card.return_stats_from_resource(file_path)
		card.is_preview = true
		is_in_preview = true
		card.get_node("visible").scale = Vector2(1, 1)
		card.set_custom_minimum_size(Vector2(397, 584)) 
		card.get_node("anims").play('fade_in')
		$CenterContainer.visible = true
		$CenterContainer.add_child(card)


func _on_save_pressed() -> void:
	Saves.save(Saves.SaveTypes.BATTLE)
func _on_clear_pressed() -> void:
	for deck in $snap_container.get_children():
		for snap in deck.get_children():
			if snap.card != null:
				snap.card.clear_snap(false)
	_on_held_card_let_go()

func _on_shuffle_pressed() -> void:
	_on_clear_pressed()
	
	var all_cards = %card_container.get_children()
	all_cards.shuffle()
	
	for i in range($snap_container.get_node(cur_deck).get_children().size()):
		$snap_container.get_node(cur_deck).get_children()[i].lock_card(all_cards[i])


func add_blank(daPos):
	var blank = Control.new()
	blank.size = Vector2(149, 216)
	blank.position = daPos
	%card_container.add_child(blank)


func _on_type_item_selected(index: int) -> void:
	_on_clear_pressed()
	match index:
		0:
			cur_deck = "8 Cards"
		1:
			cur_deck = "9 Cards"
		2:
			cur_deck = "10 Cards"
		3:
			cur_deck = "11 Cards"
		4:
			cur_deck = "12 Cards"
	for deck in decks:
		if deck.name != cur_deck:
			deck.visible = false
		else:
			deck.visible = true
	set_deck()


func _on_type_toggled(toggled_on: bool) -> void:
	if toggled_on:
		global.mouse.make_hidden()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	else:
		global.mouse.make_visible()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)


func _on_click_detection_pressed() -> void:
	await get_tree().process_frame
	$dark.visible = false
	is_in_preview = false
	for child in $CenterContainer.get_children():
		child.queue_free()
