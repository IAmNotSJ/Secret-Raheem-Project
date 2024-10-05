@tool
class_name DraggableCard
extends Control

enum Rarity {
	COMMON,
	HOLO
}
var rarity:Rarity = Rarity.COMMON

signal picked_up
signal let_go
signal right_clicked

@export_category("Resource")
@export var stats:CardStats = load("res://minigames/raheem_battle/cards/card_variants/stats/0.tres")

const holoShader = preload("res://minigames/raheem_battle/cards/holographic.gdshader")

var held
var original_position:Vector2 = Vector2(0, 0)

var snap:CardSnap = null

var offset:int = 0
var shader_offset:float = 0.1

#For one use abilities. Set to true to make ability not work
var ability_used:bool = false


func _ready():
	if rarity == Rarity.HOLO:
		$visible.material.set("shader_parameter/active", true)
	
	_on_stats_changed()
	stats.changed.connect(_on_stats_changed)
	
	await get_tree().process_frame
	original_position = position

func _input(_event: InputEvent) -> void:
	# i GENUINELY have no idea what the fuck was wrong with this
	if $mouse_detection.get_overlapping_areas() != []:
		if Input.is_action_just_pressed("click"):
			get_parent().get_parent().get_parent().set_held(self)
			picked_up.emit()
			if snap != null:
				Saves.battle_deck["Card " + str(snap.deck_index)] = "-1"
				snap.card = null
				snap = null
		if Input.is_action_just_pressed("right_click"):
			print('poo')
			get_parent().get_parent().get_parent().generate_preview(stats.card_number)

func _on_stats_changed():
	if stats != null:
		%Name.text = stats.card_name
		
		_update_label_size(%Name)
		
		%Series.text = stats.card_series
		%Number.text = stats.card_number
		
		change_color(stats.card_series)
		
		if stats.hide_stats:
			%Ability.text = "X"
			%Defense.text = "X"
		else:
			if stats.true_attack == 6.5:
				%Attack.text = "Ϫ"
			else:
				%Attack.text = str(stats.true_attack)
			if stats.true_defense == 6.5:
				%Defense.text = "Ϫ"
			else:
				%Defense.text = str(stats.true_defense)
		
		%icon.texture = load("res://minigames/raheem_battle/cards/card_variants/assets/" + stats.card_number + ".png")
		
		%Ability_Name.text = stats.ability_name
		#print(stats.ability_name)
		%Ability_Description.text = stats.ability_description
		
		
		if stats.ability_name == "" or stats.ability_name == " ":
			%Ability_Holder.visible = false
		else:
			%Ability_Holder.visible = true

func export():
	var daExport:Dictionary = {
	"Name" : stats.card_name,
	"Series" : stats.card_series,
	"Number" : stats.card_number,
	"Attack" : stats.true_attack,
	"Defense" : stats.true_defense,
	"Base Attack" : stats.base_attack,
	"Base Defense" : stats.base_defense,
	"Bonus Attack" : stats.get_bonus_attack(),
	"Bonus Defense" : stats.get_bonus_defense(),
	"Penalty Attack" : stats.get_penalty_attack(),
	"Penalty Defense" : stats.get_penalty_defense(),
	"Can Get Bonuses" : stats.can_get_bonuses,
	"Ability" : stats.ability_name,
	"Ability Description" : stats.ability_description,
	"One Use Ability" : stats.one_use_ability,
	"Ability Used" : ability_used,
	"Hide Stats" : stats.hide_stats,
	"Is Human" : stats.is_human,
	"Has Hands" : stats.has_hands,
	"Bonuses" : stats.bonuses,
	"Penalties" : stats.penalties,
	"Should Remove" : stats.should_remove
	}
	return daExport

func _update_label_size(label):
	var sizes:Dictionary = {
		"41" : [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
		"39" : [12, 13],
		"34" : [14],
		"30" : [15],
		"26" : [16, 17, 18],
		"23" : [19, 20, 21, 22]
	}
	for key in sizes.keys():
		for length in sizes[key]:
			if label.text.length() == length:
				label.add_theme_font_size_override("font_size", int(key))

func set_base_attack(val):
	stats.base_attack = val
func set_base_defense(val):
	stats.base_defense = val

func change_color(series):
	var last_color = modulate
	var color = Color8(255, 255, 255, 255)
	match series:
		"Raheem":
			color = Color8(61, 158, 255)
		"Wibr":
			color = Color8(255, 61, 145)
		"SJ":
			color = Color8(46, 255, 171)
		"Cleft":
			color = Color8(76, 191, 0)
		"Block":
			color = Color8(171, 220, 235)
		"Cherry":
			color = Color8(63, 54, 181)
		"Dapper":
			color = Color8(0, 255, 157)
		"Slime":
			color = Color8(255, 183, 0)
		"Atlas":
			color = Color8(217, 217, 217)
		"Dile":
			color = Color8(255, 69, 239)
		"Composty":
			color = Color8(56, 255, 69)
		"Cost":
			color = Color8(255, 177, 135)
		"Lambda":
			color = Color8(255, 103, 20)
		"Luna":
			color = Color8(17, 168, 70)
	
	%Base.modulate = color
	%border.modulate = color
	%Ability_Holder.modulate = color.lightened(0.2)
	
	
	if last_color != color:
		if rarity == Rarity.HOLO:
			var gradient = Gradient.new()
			gradient.add_point(0, Color.WHITE.lerp(color, 0.6))
			gradient.add_point(0.309, Color("45d5fc").lerp(color, 0.6))
			gradient.add_point(0.614, Color("60d665").lerp(color, 0.6))
			gradient.add_point(0.831, Color("ffd319").lerp(color, 0.6))
			gradient.add_point(1, Color.BLACK.lerp(color, 0.6))
			
			var texture_grad = GradientTexture1D.new()
			texture_grad.gradient = gradient
			$visible.material.set("shader_parameter/gradient", texture_grad)

func _on_let_go():
	var snaps = []
	if $snap_detection.has_overlapping_areas():
		for area in $snap_detection.get_overlapping_areas():
			if area.owner is CardSnap:
				if area.owner.card == null:
					snaps.append(area.owner)
	
	if snaps != []:
		var lowest_snap_distance:float = 5000
		var daIndex:int = 0
		for i in snaps.size():
			var snap_pos:Vector2
			snap_pos.x = snaps[i].global_position.x
			snap_pos.y = snaps[i].global_position.y
			var card_pos:Vector2
			card_pos.x = global_position.x
			card_pos.y = global_position.y
			var snap_distance:float = card_pos.distance_to(snap_pos)
			if snap_distance < lowest_snap_distance:
				lowest_snap_distance = snap_distance
				daIndex = i
			#print("SNAP INDEX " + str(snaps[i].deck_index) + " DISTANCE :" + str(snap_distance))
		#print("LOWEST SNAP DISTANCE: " + str(lowest_snap_distance))
		if snaps[daIndex].card == null:
			snaps[daIndex].lock_card(self)
	else:
		position = original_position
		reparent(get_parent().get_parent().get_parent().get_node("ScrollContainer/card_container"))
		
		
		var index = int(stats.card_number)
		for num in get_parent().get_parent().get_parent().cards_removed:
			if int(num) < index:
				index -= 1
		get_parent().move_child(self, index)
		
		get_parent().get_parent().get_parent().cards_removed.erase(stats.card_number)
		print(get_parent().get_parent().get_parent().cards_removed)
