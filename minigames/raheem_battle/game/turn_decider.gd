extends Node

#ANOTHER copy of the enum in game
enum Sides {
	ATTACKING,
	DEFENDING,
	TIE
}

@onready var game = get_parent().get_parent()




# Returns the side that wins, duh
func decide_outcome(attacking_card, defending_card, attacking_info, defending_info):
	var decision:Sides
	if attacking_card["True Attack"] > defending_card["True Defense"]:
		decision = Sides.ATTACKING
	else:
		decision = Sides.DEFENDING
	
	var ability_factor = _factor_abilities(decision, attacking_card, defending_card, attacking_info, defending_info)
	if ability_factor != null:
		if ability_factor != decision:
			decision = ability_factor
	
	return decision
	

# Abilities to factor for:
# Wealth
# Sand Veil
func _factor_abilities(decision, attacking_card, defending_card, attacking_info, defending_info):
	var final_decision:Sides = decision
	# Checks to see if the attacking/defending card will win the interaction. If both vars are true,
	# Return Sides. DEFENDING. If both are false, return null. If only one wins, return the side
	# Associated with that value
	var attacking_wins:int = 0
	var defending_wins:int = 0
	var is_tie1:bool = false
	var is_tie2:bool = false
	
	# 1 means TRUE
	# 0 means FALSE
	# -1 means LOSS
	attacking_wins = _factor_side(attacking_card, defending_card, attacking_info, defending_info)
	defending_wins = _factor_side(defending_card, attacking_card, defending_info, attacking_info)
	
	if attacking_wins == 1 and defending_wins == 1:
		final_decision = Sides.DEFENDING
	elif attacking_wins == 1 and defending_wins == 0:
		final_decision = Sides.ATTACKING
	elif attacking_wins == 0 and defending_wins == 1:
		final_decision = Sides.DEFENDING
	elif attacking_wins == -1 and defending_wins != -1:
		final_decision = Sides.DEFENDING
	elif defending_wins == -1 and attacking_wins != -1:
		final_decision = Sides.ATTACKING
	elif defending_wins == -1 and attacking_wins == -1:
		final_decision = Sides.DEFENDING
	
	is_tie1 = _factor_tie(attacking_card, defending_card, final_decision)
	is_tie2 = _factor_tie(defending_card, attacking_card, final_decision)
	
	if is_tie1 or is_tie2:
		final_decision = Sides.TIE
	
	return final_decision

#Returns 1 if the card wins
func _factor_side(card, opposing_card, info, opposing_info):
	match card["Ability Name"]:
		"Wealth":
			return 1
		"True Gamer":
			if card["Side"] == Sides.ATTACKING:
				if card["True Attack"] == opposing_card["True Defense"]:
					return 1
		"Nectar of the Gods":
			return -1
		"Espionage":
			if card["Side"] == Sides.DEFENDING:
				if opposing_card["True Attack"] > card["True Defense"] + 3:
					return 1
		"Muppet of a Man":
			if opposing_card["Is Human"] == true:
				return -1
		"Extremely Pressable":
			if opposing_card["Has Hands"] == true:
				return -1
		"IOU":
			var random = randi_range(1, 20)
			if random == 1 or random == 2 or random == 3:
				return 1
		"Bigger Fish":
			var opposing_card_total = opposing_card["True Attack"] + opposing_card["True Defense"]
			
			if opposing_card_total <= 6:
				return 1
		"Wolve's Bane":
			if opposing_info["Quiz"]["Furry"]:
				if randi_range(1, 2) == 1:
					return 1
		"Debug":
			if opposing_card["Card Series"] == "SJ":
				return -1
		"Kill Count":
			if info["Stats"]["Wins"] > opposing_info["Stats"]["Games Played"]:
				return 1
		"The Yellow One":
			if randi_range(1, 12) == 1:
				return -1
		"Troll":
			if randi_range(1, 4) == 1:
				return 1
			else:
				return -1
	return 0

# Returns true if real tie
func _factor_tie(card, opposing_card, decision):
	match card["Ability Name"]:
		"Sand Veil":
			if decision == opposing_card["Side"] and randi_range(0, 1) == 0:
				return true
		"Freddy Mask":
			if decision == opposing_card["Side"] and game.turn_count <= 3:
				return true
		".":
			if !card["Ability Used"]:
				return true
	return false
