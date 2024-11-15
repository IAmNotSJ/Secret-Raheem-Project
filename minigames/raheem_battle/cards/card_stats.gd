@tool
class_name CardStats extends Resource

signal bonus_added(amount:int, key:String)
signal penalty_added(amount:int, key:String)

@export_category("Details")
@export var card_name:String = "Test Card" :
	set(value):
		card_name = value
		emit_changed()
@export var censored_name:String = ""
@export var card_series:String = "Test Series" :
	set(value):
		card_series = value
		emit_changed()
@export var card_number:String = "0" :
	set(value):
		card_number = value
		emit_changed()

@export_category("Stats")
@export var base_attack:float = 1 :
	set(value):
		base_attack = value
		_recalculate_attack()
		emit_changed()
@export var base_defense:float = 1 :
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
@export_multiline var ability_description:String :
	set(value):
		ability_description = value
		emit_changed()

@export var one_use_ability:bool = false :
	set(value):
		one_use_ability = value
		emit_changed()

@export var should_remove:bool = true
## Hides the card's stats until use
@export var hide_stats:bool = false

@export_category("Miscellaneous")
@export var is_human:bool = false
@export var has_hands:bool = false

# ########################################### UNCHANGEABLE STATS ######################################### #

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
	"The Answer" : [0, 0],
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
	"Hosting" : [0, 0]
}

#Update this with every single ability that can give stat bonuses
var penalties:Dictionary = {
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
}

var stashed_bonuses = {}
var stashed_penalties = {}

# EXAMPLE OF A STASHED KEY
#{
#	"Revenge Shot" : [[2, 3], [false, false]]
#}
#	"Revenge Shot" is the key of the ability
#	[2, 3] is the bonus array ([Attack/Defense])
#	[false, false] is to OVERRIDE attack/defense. Because its false, it does not.

var true_attack:float
var true_defense:float



func _ready():
	_recalculate_attack()
	_recalculate_defense()
	emit_changed()

func clear_bonuses():
	for bonus in bonuses.keys():
		bonuses[bonus] = [0, 0]

func get_bonus_attack():
	var bonus_attack:float = 0
	for bonus in bonuses.keys():
		bonus_attack += bonuses[bonus][0]
	return bonus_attack

func get_bonus_defense():
	var bonus_defense:float = 0
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
		if stashed_bonuses.has(key):
			if stashed_bonuses[key][1][0] == false:
				stashed_bonuses[key][0][0] += amount
		else:
			stashed_bonuses[key] = [[amount, 0], [false, false]]

@rpc("any_peer")
func set_bonus_attack(amount, key):
	if can_get_bonuses:
		if stashed_bonuses.has(key):
			stashed_bonuses[key][0][0] = amount
			stashed_bonuses[key][1][0] = true
		else:
			stashed_bonuses[key] = [[amount, 0], [true, true]]

@rpc("any_peer")
func add_bonus_defense(amount, key):
	if can_get_bonuses:
		if stashed_bonuses.has(key):
			if stashed_bonuses[key][1][1] == false:
				stashed_bonuses[key][0][1] += amount
		else:
			stashed_bonuses[key] = [[0, amount], [false, false]]

@rpc("any_peer")
func set_bonus_defense(amount, key):
	if can_get_bonuses:
		if stashed_bonuses.has(key):
			stashed_bonuses[key][0][1] = amount
			stashed_bonuses[key][1][1] = true
		else:
			stashed_bonuses[key] = [[0, amount], [true, true]]

@rpc("any_peer")
func set_bonuses(bonus_dict:Dictionary):
	if can_get_bonuses:
		bonuses = bonus_dict
		_recalculate_attack()
		_recalculate_defense()

@rpc("any_peer")
func add_penalty_attack(amount, key):
	if stashed_penalties.has(key):
		if stashed_penalties[key][1][0] == false:
			stashed_penalties[key][0][0] += amount
	else:
		stashed_penalties[key] = [[amount, 0], [false, false]]

@rpc("any_peer")
func set_penalty_attack(amount, key):
	if stashed_penalties.has(key):
		stashed_penalties[key][0][0] = amount
		stashed_penalties[key][1][0] = true
	else:
		stashed_penalties[key] = [[amount, 0], [true, true]]

@rpc("any_peer")
func add_penalty_defense(amount, key):
	if stashed_penalties.has(key):
		if stashed_penalties[key][1][1] == false:
			stashed_penalties[key][0][1] += amount
	else:
		stashed_penalties[key] = [[0, amount], [false, false]]

@rpc("any_peer")
func set_penalty_defense(amount, key):
	if stashed_penalties.has(key):
		stashed_penalties[key][0][1] = amount
		stashed_penalties[key][1][1] = true
	else:
		stashed_penalties[key] = [[0, amount], [true, true]]

@rpc("any_peer")
func set_penalties(penalty_dict:Dictionary):
	penalties = penalty_dict
	_recalculate_attack()
	_recalculate_defense()

func apply_bonuses():
	var bonuses_added:bool = false
	for bonus in stashed_bonuses.keys():
		if stashed_bonuses[bonus][1][0] == false:
			bonuses[bonus][0] += stashed_bonuses[bonus][0][0]
			bonus_added.emit(stashed_bonuses[bonus][0][0], "Attack")
			bonuses_added = true
		else:
			bonuses[bonus][0] = stashed_bonuses[bonus][0][0]
			bonuses_added = true
		
		if stashed_bonuses[bonus][1][1] == false:
			bonuses[bonus][1] += stashed_bonuses[bonus][0][1]
			bonus_added.emit(stashed_bonuses[bonus][0][1], "Defense")
			bonuses_added = true
		else:
			bonuses[bonus][1] = stashed_bonuses[bonus][0][1]
			bonuses_added = true
	
	# Flooring for thrembo
	if bonuses_added:
		base_attack = floor(base_attack)
		base_defense = floor(base_defense)
	
	stashed_bonuses = {}
	_recalculate_defense()
	_recalculate_attack()
	emit_changed()

func apply_penalties():
	var penalties_added:bool = false
	for penalty in stashed_penalties.keys():
		if stashed_penalties[penalty][1][0] == false:
			penalties[penalty][0] += stashed_penalties[penalty][0][0]
			penalty_added.emit(stashed_penalties[penalty][0][0], "Attack")
			penalties_added = true
		else:
			penalties[penalty][0] = stashed_penalties[penalty][0][0]
			penalties_added = true
		
		if stashed_penalties[penalty][1][1] == false:
			penalties[penalty][1] += stashed_penalties[penalty][0][1]
			penalty_added.emit(stashed_penalties[penalty][0][1], "Defense")
			penalties_added = true
		else:
			penalties[penalty][1] = stashed_penalties[penalty][0][1]
			penalties_added = true
	
	# Flooring for thrembo
	if penalties_added:
		base_attack = floor(base_attack)
		base_defense = floor(base_defense)
	
	stashed_penalties = {}
	_recalculate_defense()
	_recalculate_attack()
	emit_changed()

func _recalculate_attack():
	true_attack = base_attack + get_bonus_attack() - get_penalty_attack()
	if true_attack < 0:
		true_attack = 0

func _recalculate_defense():
	true_defense = base_defense + get_bonus_defense() - get_penalty_defense()
	if true_defense < 0:
		true_defense = 0
