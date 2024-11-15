class_name DraggableCard
extends Control

enum Rarity {
	COMMON,
	HOLO
}
var rarity:Rarity = Rarity.COMMON

signal picked_up
signal let_go
signal taken_out
signal right_clicked

signal snap_locked

@export_category("Resource")
#@export var stats:CardStats = load("res://minigames/raheem_battle/cards/card_variants/stats/0.tres")

@export var is_preview:bool = false
@export var selectable:bool = true
@export var do_offset_bullshit:bool = false

const holoShader = preload("res://minigames/raheem_battle/shaders/holographic.gdshader")

var menu
var deck_builder

var can_click:bool = false

var index:int

var offset:int = 0
var shader_offset:float = 0.1

var stats:Dictionary = {
	"Card Name" : "Hampter",
	"Card Series" : "Test Series",
	"Card Number" : "0",
	"Base Attack" : 1,
	"Base Defense" : 1,
	"Bonus Attack" : 0,
	"Bonus Defense" : 0,
	"Penalty Attack" : 0,
	"Penalty Defense" : 0,
	"Bonuses" : 
		{
		"Revenge Shot" : [0, 0],
		"Boost" : [0, 0],
		"Kindness" : [0, 0],
		"Price Goes Up Yearly" : [0, 0],
		"Gamer Rage" : [0, 0],
		"Up and Coming" : [0, 0],
		"Speeding" : [0, 0],
		"Deadline" : [0, 0],
		"Other Priorities" : [0, 0],
		"Cash Out": [0, 0],
		"Rising" : [0, 0],
		"Post-Mortem" : [0, 0],
		"Winter Scavenging" : [0, 0],
		"Nectar of the Gods" : [0, 0],
		"Reminiscing" : [0, 0],
		"Paranoia" : [0, 0],
		"What Day Is It?" : [0, 0],
		"Editing" : [0, 0],
		"Categorical Knowledge" : [0, 0],
		"Transform" : [0, 0],
		"Walk" : [0, 0],
		"Grazing" : [0, 0],
		"Chincanery" : [0, 0],
		"Take Batteries" : [0, 0],
		"Ambush Predator" : [0, 0],
		"Employment" : [0, 0],
		"Anrgry and Senile" : [0, 0],
		"Debt" : [0, 0],
		"Awareness" : [0, 0],
		"Speedrun" : [0, 0],
		"Top 100" : [0, 0],
		"Leaderboard" : [0, 0],
		"Spreadsheet" : [0, 0],
		"Charity" : [0, 0],
		"Truest Nemo" : [0, 0],
		"Sensitive" : [0, 0],
		"Three Handed" : [0, 0],
		"Fangirl" : [0, 0],
		"Dance" : [0, 0],
		"Hosting" : [0, 0],
		"Awesome Ogre" : [0, 0],
		"Generic Response" : [0, 0],
		"The Grind" : [0, 0],
		"Denmark" : [0, 0],
		"Dice Roll" : [0, 0],
		"Extra Space" : [0, 0]
		},
	"Penalties": 
		{
		"Fire" : [0, 0],
		"Unfunny Tag" : [0, 0],
		"Speeding" : [0, 0],
		"Other Priorities" : [0, 0],
		"All Powerful" : [0, 0],
		"Acidic" : [0, 0],
		"Bathroom Break" : [0, 0],
		"Haunt" : [0, 0],
		"Take Batteries" : [0, 0],
		"Brainrot" : [0, 0],
		"Anrgry and Senile" : [0, 0],
		"Debt" : [0, 0],
		"Last Live: 3 Months Ago" : [0, 0],
		"Effort Tag" : [0, 0],
		"Insults" : [0, 0],
		"Crack" : [0, 0],
		"Comments" : [0, 0],
		"Donkey Kong" : [0, 0]
		},
	"True Attack": 1,
	"True Defense": 1,
	"Can Get Bonuses" : false,
	"Fire" : false,
	"Ability Name" : "",
	"Ability Description" : "",
	"One Use Ability" : false,
	"Should Remove" : true,
	"Hide Stats" : false,
	"Is Human" : false,
	"Has Hands" : true,
}

var held
var original_position:Vector2 = Vector2(0, 0)

var snap:CardSnap = null


func _ready():
	if rarity == Rarity.HOLO:
		$visible.material.set("shader_parameter/active", true)
	let_go.connect(_on_let_go)
	
	await get_tree().process_frame
	original_position = position
	menu = get_tree().get_root().get_node("SceneManager").get_node("battle-manager").current_scene
	deck_builder = get_tree().get_root().get_node("SceneManager").get_node("battle-manager").current_scene.get_node("ALL").get_node("deck_builder")

func _input(_event: InputEvent) -> void:
	# i GENUINELY have no idea what the fuck was wrong with this
	if $mouse_detection.get_overlapping_areas() != []:
		if Input.is_action_just_pressed("click") and menu.current_screen == menu.DECK:
			if !deck_builder.is_in_preview:
				deck_builder.set_held(self)
				picked_up.emit()
				set_card_scale(Vector2(0.4, 0.4), true)
				if snap != null:
					clear_snap()
		if Input.is_action_just_pressed("right_click"):
			deck_builder.generate_preview(stats["Card Number"])

func _on_stats_changed():
	if stats != null:
		%Name.text = stats["Card Name"]
		
		_update_label_size(%Name)
		
		%Series.text = stats["Card Series"]
		%Number.text = stats["Card Number"]
		
		change_color(stats["Card Series"])
		
		if stats["Hide Stats"]:
			%Attack.text = "X"
			%Defense.text = "X"
		else:
			if stats["True Attack"] == 6.5:
				%Attack.text = "Ϫ"
			else:
				%Attack.text = str(stats["True Attack"])
			if stats["True Defense"] == 6.5:
				%Defense.text = "Ϫ"
			else:
				%Defense.text = str(stats["True Defense"])
		
		var path:String = ""
		
		if FileAccess.file_exists("res://minigames/raheem_battle/cards/card_variants/assets/" + stats["Card Number"] + "-c.png") and Saves.battle_settings["Censor Food"]:
			path = "res://minigames/raheem_battle/cards/card_variants/assets/" + stats["Card Number"] + "-c.png"
		else:
			path = "res://minigames/raheem_battle/cards/card_variants/assets/" + stats["Card Number"] + ".png"
		%icon.texture = load(path)
		
		%Ability_Name.text = stats["Ability Name"]
		%Ability_Description.text = stats["Ability Description"]
		
		%hand.visible = stats["Has Hands"]
		%fire.visible = stats["Fire"]
		%chest.visible = stats["Should Remove"]
		%human.visible = stats["Is Human"]
		%one_use.visible = stats["One Use Ability"]
		%upgrades.visible = !stats["Can Get Bonuses"]
		
		if stats["Ability Name"] == "" or stats["Ability Name"] == " ":
			%Ability_Holder.visible = false
		else:
			%Ability_Holder.visible = true


func export():
	var daExport:Dictionary = stats.duplicate(true)
	daExport["Ability Used"] = false
	return daExport

func _update_label_size(label):
	var sizes:Dictionary = {
		"41" : [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
		"39" : [12, 13],
		"34" : [14],
		"30" : [15],
		"26" : [16, 17, 18],
		"23" : [19, 20, 21, 22],
		"21" : [23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34]
	}
	for key in sizes.keys():
		for length in sizes[key]:
			if label.text.length() == length:
				label.add_theme_font_size_override("font_size", int(key))

func set_base_attack(val):
	stats["Base Attack"] = val
func set_base_defense(val):
	stats["Base Defense"] = val

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
		"BBB":
			color = Color8(61, 255, 151)
		"Projects":
			color = Color8(255, 51, 126)
		"Third Party":
			color = Color8(168, 172, 191)
		"Nova Bloom":
			color = Color8(15, 29, 97)
		"Nova Bloom":
			color = Color8(15, 29, 97)
		"CWAF JR!!!!!!1":
			color = Color.WHITE
	
	var base_colored = [%Base, %border, %hand, %fire, %chest, %human, %one_use, %upgrades]
	var lighter_colored = [%Ability_Holder]
	var darker_colored = [%Ability_Name, %Ability_Description, %Series, %Number, %Name, %Attack, %Defense]
	for i in range(base_colored.size()):
		base_colored[i].modulate = color
	for lighter in lighter_colored:
		lighter.modulate = color.lightened(0.3)
	for darker in darker_colored:
		darker.modulate = color.darkened(0.8)
	
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

func set_card_scale(theScale:Vector2, offset_card:bool = false):
	$visible.scale = theScale
	$mouse_detection.scale = theScale / Vector2(0.37, 0.37)
	custom_minimum_size = Vector2(398, 585) * theScale
	size = Vector2(398, 585) * theScale
	if offset_card:
		var relative_scale:Vector2 = Vector2(0.37 / theScale.x, 0.37 / theScale.y)
		$visible.position.x = size.x / 2 * relative_scale.x - size.x / 2
		$visible.position.y = size.y / 2 * relative_scale.y - size.y / 2

func clear_snap(change_deck:bool = false):
	if snap != null:
		reparent(deck_builder.get_node("ScrollContainer/card_container"))
		snap.card = null
		if change_deck == true:
			Saves.battle_deck[deck_builder.cur_deck][snap.deck_index - 1] = "-1"
		snap = null
		taken_out.emit()


func _on_let_go():
	$anims.play("place")
	var snaps = []
	if $snap_detection.has_overlapping_areas():
		for area in $snap_detection.get_overlapping_areas():
			if area.owner is CardSnap:
				if area.owner.card == null and area.owner.get_parent().visible == true:
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
		if snaps[daIndex].card == null:
			snaps[daIndex].lock_card(self)
			snap_locked.emit()
	else:
		reparent(deck_builder.get_node("ScrollContainer/card_container"))
		if snap != null:
			snap = null
		taken_out.emit()

func _recalculate_attack():
	stats["True Attack"] = stats["Base Attack"]
	if stats["True Attack"] < 0:
		stats["True Attack"] = 0

func _recalculate_defense():
	stats["True Defense"] = stats["Base Defense"]
	if stats["True Defense"] < 0:
		stats["True Defense"] = 0
