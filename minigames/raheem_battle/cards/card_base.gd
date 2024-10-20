@tool
extends Control

enum Rarity {
	COMMON,
	HOLO
}
var rarity:Rarity = Rarity.COMMON


signal left_clicked(card)
signal right_clicked(card)

@export_category("Resource")
@export var stats:CardStats = load("res://minigames/raheem_battle/cards/card_variants/stats/0.tres")

@export var is_preview:bool = false
@export var selectable:bool = true
@export var do_offset_bullshit:bool = false

const holoShader = preload("res://minigames/raheem_battle/cards/holographic.gdshader")

const status_scene = preload("res://minigames/raheem_battle/cards/status/card_status.tscn")
var statuses = []
var status_timer:float = 0

var game
var can_click:bool = false

var index:int

var fire:bool = false :
	set(value) :
		fire = value
		if fire == true:
			stats.set_penalty_attack(2, "Fire")
			stats.set_penalty_defense(2, "Fire")

var offset:int = 0
var shader_offset:float = 0.1

#For one use abilities. Set to true to make ability not work
var ability_used:bool = false

#Used for Speeding. FALSE means attack, TRUE means defense
var favor:bool = false

var disabled:bool = false :
	set(value):
		disabled = value
		if disabled:
			#$visible.material.set("shader_parameter/darkened", true)
			can_click = false
			$visible.position.y = 0 + offset
		else:
			#$visible.material.set("shader_parameter/darkened", false)
			pass
var disabled_time:int = 0

# True if the card is generated to be seen as a preview
var block_input:bool = false

func _ready():
	if index % 2 != 0 and do_offset_bullshit:
		offset = -30
	
	if !is_preview:
		game = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	
	if rarity == Rarity.HOLO:
		$visible.material.set("shader_parameter/active", true)
	
	_on_stats_changed()
	stats.changed.connect(_on_stats_changed)
	stats.bonus_added.connect(_on_bonus_added)
	
	var random = randi_range(0, 1)
	if random == 0:
		favor = false
	else:
		favor = true

func _process(delta):
	if !Engine.is_editor_hint():
		if !disabled:
			if !block_input:
				if $mouse_detection.has_overlapping_areas():
					if !is_preview:
						$visible.position.y = -50 + offset
					can_click = true
				else:
					if !is_preview:
						$visible.position.y = 0 + offset
					if selectable:
						can_click = false
				if can_click:
						if Input.is_action_just_pressed('right_click'):
							right_clicked.emit(stats)
						if Input.is_action_just_pressed("click"):
							left_clicked.emit(self)
		
		status_timer -= delta
		
		if status_timer <= 0 and statuses.size() > 0:
			if game.ui.cur_stage == game.ui.Stages.TURN:
				var status = status_scene.instantiate()
				status.text = statuses[0]
				status.position = Vector2i(0, -30)
				add_child(status)
				statuses.erase(status.text)
				status_timer = 0.8

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
		%Ability_Description.text = stats.ability_description
		
		
		if stats.ability_name == "" or stats.ability_name == " ":
			%Ability_Holder.visible = false
		else:
			%Ability_Holder.visible = true

func _on_bonus_added(amount:int, type:String):
	if amount > 0:
		var status_message:String = "+" + str(amount) + " " + type
		statuses.push_back(status_message)

func _on_turn_ended():
	if disabled_time > 0 and disabled:
		disabled_time -= 1
		
		if disabled_time <= 0:
			disabled = false

func ability_check():
	if stats.one_use_ability:
		ability_used = true

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
	if !is_preview:
		daExport["Player Name"] = game.get_player().player_name
		daExport["Player ID"] = game.get_player().name
		daExport["Side"] = game.get_player().side
		daExport["Index"] = index
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

func set_card_scale(theScale:Vector2):
	$visible.scale = theScale
	$mouse_detection.scale = theScale
	custom_minimum_size = Vector2(398, 585) * theScale
	size = Vector2(398, 585) * theScale
