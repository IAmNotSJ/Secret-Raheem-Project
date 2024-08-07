@tool
class_name CardStats extends Resource

@export_category("Details")
@export var card_name:String = "Test Card" :
	set(value):
		card_name = value
		emit_changed()
@export var card_series:String = "Test Series" :
	set(value):
		card_series = value
		emit_changed()
@export var card_number:String = "0" :
	set(value):
		card_number = value
		emit_changed()

@export_category("Stats")
@export var base_attack:int = 1 :
	set(value):
		base_attack = value
		_recalculate_attack()
		emit_changed()
@export var base_defense:int = 1 :
	set(value):
		base_defense = value
		_recalculate_defense()
		emit_changed()
@export var can_get_bonuses:bool = true :
	set(value):
		can_get_bonuses = value
		emit_changed()

@export_category("Ability")
@export var ability_name:String = "" :
	set(value):
		ability_name = value
		emit_changed()
@export var one_use_ability:bool = false :
	set(value):
		one_use_ability = value
		emit_changed()
@export_multiline var ability_description:String :
	set(value):
		ability_description = value
		emit_changed()

@export_category("Miscellaneous")
@export var should_remove:bool = true

# UNCHANGEABLE STATS

#Update this with every single ability that can give stat bonuses
var bonuses:Dictionary = {
	"Revenge Shot" : [0, 0],
	"Boost" : [0, 0],
	"Kindness" : [0, 0],
	"Price Goes Up Yearly" : [0, 0],
	"Gamer Rage" : [0, 0],
	"Up and Coming" : [0, 0],
	"Speeding" : [0, 0],
	"Deadline" : [0, 0],
	"Other Priorities" : [0, 0],
	"Cash Out": [0, 0]
}

#Update this with every single ability that can give stat bonuses
var penalties:Dictionary = {
	"Unfunny Tag" : [0, 0],
	"Speeding" : [0, 0],
	"Other Priorities" : [0, 0]
}

var true_attack:int
var true_defense:int

func _ready():
	_recalculate_attack()
	_recalculate_defense()
	emit_changed()

func clear_bonuses():
	for bonus in bonuses.keys():
		bonuses[bonus] = [0, 0]

func get_bonus_attack():
	var bonus_attack:int = 0
	for bonus in bonuses.keys():
		bonus_attack += bonuses[bonus][0]
	return bonus_attack

func get_bonus_defense():
	var bonus_defense:int = 0
	for bonus in bonuses.keys():
		bonus_defense += bonuses[bonus][1]
	return bonus_defense

func get_penalty_attack():
	var penalty_attack:int = 0
	for penalty in penalties.keys():
		penalty_attack += penalties[penalty][0]
	return penalty_attack

func get_penalty_defense():
	var penalty_defense:int = 0
	for penalty in penalties.keys():
		penalty_defense += penalties[penalty][1]
	return penalty_defense

@rpc("any_peer")
func add_bonus_attack(amount, key):
	if can_get_bonuses:
		bonuses[key][0] += amount
		_recalculate_attack()
		emit_changed()

@rpc("any_peer")
func set_bonus_attack(amount, key):
	if can_get_bonuses:
		bonuses[key][0] = amount
		_recalculate_attack()
		emit_changed()

@rpc("any_peer")
func add_bonus_defense(amount, key):
	if can_get_bonuses:
		bonuses[key][1] += amount
		_recalculate_defense()
		emit_changed()

@rpc("any_peer")
func set_bonus_defense(amount, key):
	if can_get_bonuses:
		bonuses[key][1] = amount
		_recalculate_defense()
		emit_changed()

func add_penalty_attack(amount, key):
	penalties[key][0] += amount
	_recalculate_attack()
	emit_changed()

func set_penalty_attack(amount, key):
	penalties[key][0] = amount
	_recalculate_attack()
	emit_changed()

func add_penalty_defense(amount, key):
	penalties[key][1] += amount
	_recalculate_defense()
	emit_changed()

func set_penalty_defense(amount, key):
	penalties[key][1] = amount
	_recalculate_defense()
	emit_changed()

func _recalculate_attack():
	true_attack = base_attack + get_bonus_attack() - get_penalty_attack()
	if true_attack < 0:
		true_attack = 0

func _recalculate_defense():
	true_defense = base_defense + get_bonus_defense() - get_penalty_defense()
	if true_defense < 0:
		true_defense = 0
