extends Node

#ANOTHER copy of the enum in game
enum Sides {
	ATTACKING,
	DEFENDING,
	TIE
}

@onready var game = get_parent()




# Returns the side that wins, duh
func decide_outcome(attacking_card, defending_card):
	var decision:Sides
	if attacking_card["Attack"] > defending_card["Defense"]:
		decision = Sides.ATTACKING
	else:
		decision = Sides.DEFENDING
	
	var ability_factor = _factor_abilities(attacking_card, defending_card)
	if ability_factor != null:
		if ability_factor != decision:
			decision = ability_factor
	
	return decision
	

# Abilities to factor for:
# Wealth
# Sand Veil
func _factor_abilities(attacking_card, defending_card):
	# Checks to see if the attacking/defending card will win the interaction. If both vars are true,
	# Return Sides. DEFENDING. If both are false, return null. If only one wins, return the side
	# Associated with that value
	var attacking_wins:int = 0
	var defending_wins:int = 0
	
	# 1 means TRUE
	# 0 means FALSE
	# -1 means TIE
	attacking_wins = _factor_side(attacking_card, defending_card)
	defending_wins = _factor_side(defending_card, attacking_card)
	
	if attacking_wins == -1 or defending_wins == -1:
		return Sides.TIE
	else:
		if attacking_wins == 1 and defending_wins == 1:
			return Sides.DEFENDING
		elif attacking_wins == 1 and defending_wins == 0:
			return Sides.ATTACKING
		elif attacking_wins == 0 and defending_wins == 1:
			return Sides.DEFENDING
		elif attacking_wins == 0 and defending_wins == 0:
			return

#Returns true if the card wins
func _factor_side(card, opposing_card):
	match card["Ability"]:
		"Wealth":
			return 1
		"Sand Veil":
			match card["Side"]:
				Sides.ATTACKING:
					if opposing_card["Defense"] >= card["Attack"]:
						if randi_range(0, 1) == 0:
							#print("Tie should be occuring!")
							return -1
				Sides.DEFENDING:
					if opposing_card["Attack"] > card["Defense"]:
						if randi_range(0, 1) == 0:
							#print("Tie should be occuring!")
							return -1
		"True Gamer":
			if card["Side"] == Sides.ATTACKING:
				if card["Attack"] == opposing_card["Defense"]:
					return 1
		"Freddy Mask":
			match card["Side"]:
				Sides.ATTACKING:
					if opposing_card["Defense"] >= card["Attack"]:
						if game.turn_count <= 3:
							return -1
				Sides.DEFENDING:
					if opposing_card["Attack"] > card["Defense"]:
						if game.turn_count <= 3:
							return -1
		
	return 0
