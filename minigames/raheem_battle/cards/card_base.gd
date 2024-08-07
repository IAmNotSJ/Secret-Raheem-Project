@tool
extends Control

signal selected(card)

@export_category("Resource")
@export var stats:CardStats = load("res://minigames/raheem_battle/cards/card_variants/stats/0.tres")


@onready var game = get_parent().get_parent().get_parent().get_parent()
@onready var ui = get_parent().get_parent().get_parent()
@onready var card_hand = get_parent().get_parent()

var can_click:bool = false

var index:int

var offset:int = 0

#For one use abilities. Set to true to make ability not work
var ability_used:bool = false

#Used for Speeding. FALSE means attack, TRUE means defense
var favor:bool = false

var disabled:bool = false :
	set(value):
		disabled = value
		if disabled:
			%Base.color = Color(100, 100, 100, 255)
			can_click = false
			$visible.position.y = 0 + offset
		else:
			%Base.color = Color(255, 255, 255, 255)
var disabled_time:int = 0

# True if the card is generated to be seen as a preview
var block_input:bool = false

func _ready():
	if index % 2 != 0:
		offset = -30
	
	stats.changed.connect(_on_stats_changed)
	if !Engine.is_editor_hint():
		ui.turn_ended.connect(_on_turn_ended)
	_on_stats_changed()
	
	var random = randi_range(0, 1)
	if random == 0:
		favor = false
	else:
		favor = true

func _process(_delta):
	if !Engine.is_editor_hint():
		if !disabled:
			if !block_input:
				if $mouse_detection.has_overlapping_areas():
					$visible.position.y = -50 + offset
					can_click = true
				else:
					$visible.position.y = 0 + offset
					can_click = false
				if can_click:
					if Input.is_action_just_pressed('right_click'):
						ui.card_preview.generate_card_preview(stats)
					if Input.is_action_just_pressed("click") and game.started:
						selected.emit(self)


func _on_stats_changed():
	if stats != null:
		%Name.text = stats.card_name
		%Series.text = stats.card_series
		%Number.text = stats.card_number
		
		%Attack.text = str(stats.true_attack)
		%Defense.text = str(stats.true_defense)
		
		%icon.texture = load("res://minigames/raheem_battle/cards/card_variants/assets/" + stats.card_number + ".png")
		
		%Ability_Name.text = stats.ability_name
		%Ability_Description.text = stats.ability_description
		
		if stats.ability_name == "" or stats.ability_name == " ":
			%Ability_Holder.visible = false
		else:
			%Ability_Holder.visible = true

func _on_turn_ended():
	#print('turn ended!')
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
	"Bonuses" : stats.bonuses,
	"Penalties" : stats.penalties,
	"Should Remove" : stats.should_remove,
	"Player Name" : game.get_player().player_name,
	"Side" : game.get_player().side,
	"Index" : index
	}
	return daExport
