@tool
extends Control

enum Rarity {
	COMMON,
	HOLO
}
var rarity:Rarity = Rarity.COMMON


signal left_clicked(card)
signal right_clicked(card)

signal bonus_added(amount:int, key:String)
signal penalty_added(amount:int, key:String)
signal changed

@export_category("Resource")
#@export var stats:CardStats = load("res://minigames/raheem_battle/cards/card_variants/stats/0.tres")

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
			send_card_status("Disabled!")
			can_click = false
			$visible.position.y = 0 + offset
			$visible.modulate = Color(0.2, 0.2, 0.2)
		else:
			#$visible.material.set("shader_parameter/darkened", false)
			$visible.modulate = Color(1, 1, 1)
var disabled_time:int = 0

# True if the card is generated to be seen as a preview
var block_input:bool = false

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
		"The Grind" : [0, 0]
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

var stashed_bonuses = {}
var stashed_penalties = {}

func _ready():
	if index % 2 != 0 and do_offset_bullshit:
		offset = -30
	
	if !is_preview:
		game = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	
	if rarity == Rarity.HOLO:
		$visible.material.set("shader_parameter/active", true)
	
	changed.connect(_on_stats_changed)
	bonus_added.connect(_on_bonus_added)
	penalty_added.connect(_on_penalty_added)
	
	var random = randi_range(0, 1)
	if random == 0:
		favor = false
	else:
		favor = true
	
	_recalculate_attack()
	_recalculate_defense()
	changed.emit()

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
		
		%icon.texture = load("res://minigames/raheem_battle/cards/card_variants/assets/" + stats["Card Number"] + ".png")
		
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

func _on_bonus_added(amount:int, type:String):
	if amount > 0:
		var status_message:String = "+" + str(amount) + " " + type
		send_card_status(status_message)

func _on_penalty_added(amount:int, type:String):
	if amount > 0:
		var status_message:String = "-" + str(amount) + " " + type
		send_card_status(status_message)

func send_card_status(message:String):
	if !stats["Hide Stats"]:
		statuses.push_back(message)

func _on_turn_ended():
	if disabled_time > 0 and disabled:
		disabled_time -= 1
		
		if disabled_time <= 0:
			disabled = false

func ability_check():
	if stats["One Use Ability"]:
		ability_used = true

func export():
	var daExport:Dictionary = stats.duplicate(true)
	if !is_preview:
		daExport["Player Name"] = game.get_player().player_name
		daExport["Player ID"] = game.get_player().name
		daExport["Side"] = game.get_player().side
		daExport["Index"] = index
		daExport["Ability Used"] = ability_used
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

func set_card_scale(theScale:Vector2):
	$visible.scale = theScale
	$mouse_detection.scale = theScale / Vector2(0.37, 0.37)
	custom_minimum_size = Vector2(398, 585) * theScale
	size = Vector2(398, 585) * theScale


# ---- STAT FUNCTIONS ---- #

func clear_bonuses():
	for bonus in stats["Bonuses"].keys():
		stats["Bonuses"][bonus] = [0, 0]

func clear_penalties():
	for bonus in stats["Penalties"].keys():
		stats["Penalties"][bonus] = [0, 0]

func _recalculate_attack():
	stats["True Attack"] = stats["Base Attack"] + get_bonus_attack() - get_penalty_attack()
	if stats["True Attack"] < 0:
		stats["True Attack"] = 0

func _recalculate_defense():
	stats["True Defense"] = stats["Base Defense"] + get_bonus_defense() - get_penalty_defense()
	if stats["True Defense"] < 0:
		stats["True Defense"] = 0

func get_bonus_attack():
	var bonus_attack:float = 0
	for bonus in stats["Bonuses"].keys():
		bonus_attack += stats["Bonuses"][bonus][0]
	return bonus_attack

func get_bonus_defense():
	var bonus_defense:float = 0
	for bonus in stats["Bonuses"].keys():
		bonus_defense += stats["Bonuses"][bonus][1]
	return bonus_defense

func get_penalty_attack():
	var penalty_attack:int = 0
	for penalty in stats["Penalties"].keys():
		penalty_attack +=  stats["Penalties"][penalty][0]
	return penalty_attack

func get_penalty_defense():
	var penalty_defense:int = 0
	for penalty in  stats["Penalties"].keys():
		penalty_defense +=  stats["Penalties"][penalty][1]
	return penalty_defense

@rpc("any_peer")
func add_bonus_attack(amount, key):
	if stats["Can Get Bonuses"]:
		if stashed_bonuses.has(key):
			if stashed_bonuses[key][1][0] == false:
				stashed_bonuses[key][0][0] += amount
		else:
			stashed_bonuses[key] = [[amount, 0], [false, false]]

@rpc("any_peer")
func set_bonus_attack(amount, key):
	if stats["Can Get Bonuses"]:
		if stashed_bonuses.has(key):
			stashed_bonuses[key][0][0] = amount
			stashed_bonuses[key][1][0] = true
		else:
			stashed_bonuses[key] = [[amount, 0], [true, true]]

@rpc("any_peer")
func add_bonus_defense(amount, key):
	if stats["Can Get Bonuses"]:
		if stashed_bonuses.has(key):
			if stashed_bonuses[key][1][1] == false:
				stashed_bonuses[key][0][1] += amount
		else:
			stashed_bonuses[key] = [[0, amount], [false, false]]

@rpc("any_peer")
func set_bonus_defense(amount, key):
	if stats["Can Get Bonuses"]:
		if stashed_bonuses.has(key):
			stashed_bonuses[key][0][1] = amount
			stashed_bonuses[key][1][1] = true
		else:
			stashed_bonuses[key] = [[0, amount], [true, true]]

@rpc("any_peer")
func set_bonuses(bonus_dict:Dictionary):
	if stats["Can Get Bonuses"]:
		stats["Bonuses"] = bonus_dict
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
	stats["Penalties"] = penalty_dict
	_recalculate_attack()
	_recalculate_defense()

func apply_bonuses():
	var bonuses_added:bool = false
	#print('APPLYING BONUSES')
	for bonus in stashed_bonuses.keys():
		if stashed_bonuses[bonus][1][0] == false:
			stats["Bonuses"][bonus][0] += stashed_bonuses[bonus][0][0]
			#print("Adding +" + stashed_bonuses[bonus][0][0] + " Bonus Attack!")
			bonus_added.emit(stashed_bonuses[bonus][0][0], "Attack")
			bonuses_added = true
		else:
			stats["Bonuses"][bonus][0] = stashed_bonuses[bonus][0][0]
			bonuses_added = true
		
		if stashed_bonuses[bonus][1][1] == false:
			stats["Bonuses"][bonus][1] += stashed_bonuses[bonus][0][1]
			bonus_added.emit(stashed_bonuses[bonus][0][1], "Defense")
			#print("Adding +" + stashed_bonuses[bonus][0][1] + " Bonus Defense!")
			bonuses_added = true
		else:
			stats["Bonuses"][bonus][1] = stashed_bonuses[bonus][0][1]
			bonuses_added = true
	
	# Flooring for thrembo
	if bonuses_added:
		print("BONUSES HAVE BEEN ADDED")
		stats["Base Attack"] = floor(stats["Base Attack"])
		stats["Base Defense"] = floor(stats["Base Defense"])
	
	stashed_bonuses = {}
	_recalculate_defense()
	_recalculate_attack()
	changed.emit()

func apply_penalties():
	var penalties_added:bool = false
	for penalty in stashed_penalties.keys():
		if stashed_penalties[penalty][1][0] == false:
			stats["Penalties"][penalty][0] += stashed_penalties[penalty][0][0]
			penalty_added.emit(stashed_penalties[penalty][0][0], "Attack")
			penalties_added = true
		else:
			stats["Penalties"][penalty][0] = stashed_penalties[penalty][0][0]
			penalties_added = true
		
		if stashed_penalties[penalty][1][1] == false:
			stats["Penalties"][penalty][1] += stashed_penalties[penalty][0][1]
			penalty_added.emit(stashed_penalties[penalty][0][1], "Defense")
			penalties_added = true
		else:
			stats["Penalties"][penalty][1] = stashed_penalties[penalty][0][1]
			penalties_added = true
	
	# Flooring for thrembo
	if penalties_added:
		stats["Base Attack"] = floor(stats["Base Attack"])
		stats["Base Defense"] = floor(stats["Base Defense"])
	
	stashed_penalties = {}
	_recalculate_defense()
	_recalculate_attack()
	changed.emit()

func return_stats_from_resource(resource_path:String) -> Dictionary:
	var stats_resource = load(resource_path)
	
	var daExport = {
	"Card Name" : stats_resource.card_name,
	"Card Series" : stats_resource.card_series,
	"Card Number" : stats_resource.card_number,
	"Base Attack" : stats_resource.base_attack,
	"Base Defense" : stats_resource.base_defense,
	"Bonus Attack" : 0,
	"Bonus Defense" : 0,
	"Penalty Attack" : 0,
	"Penalty Defense" : 0,
	"Fire" : false,
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
		"The Grind" : [0, 0]
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
		},
	"True Attack": stats_resource.base_attack,
	"True Defense": stats_resource.base_defense,
	"Can Get Bonuses" : stats_resource.can_get_bonuses,
	"Ability Name" : stats_resource.ability_name,
	"Ability Description" : stats_resource.ability_description,
	"One Use Ability" : stats_resource.one_use_ability,
	"Should Remove" : stats_resource.should_remove,
	"Hide Stats" : stats_resource.hide_stats,
	"Is Human" : stats_resource.is_human,
	"Has Hands" : stats_resource.has_hands
	}
	return daExport

func return_stats_from_export(cardExport:Dictionary) -> Dictionary:
	var daExport = {
	"Card Name" : cardExport["Card Name"],
	"Card Series" : cardExport["Card Series"],
	"Card Number" : cardExport["Card Number"],
	"Base Attack" : cardExport["Base Attack"],
	"Base Defense" : cardExport["Base Defense"],
	"Bonus Attack" : cardExport["Bonus Attack"],
	"Bonus Defense" : cardExport["Bonus Defense"],
	"Penalty Attack" : cardExport["Penalty Attack"],
	"Penalty Defense" : cardExport["Penalty Defense"],
	"Bonuses" : cardExport["Bonuses"],
	"Penalties" : cardExport["Penalties"],
	"True Attack": cardExport["True Attack"],
	"True Defense": cardExport["True Defense"],
	"Can Get Bonuses" : cardExport["Can Get Bonuses"],
	"Fire" : cardExport["Fire"],
	"Ability Name" : cardExport["Ability Name"],
	"Ability Description" : cardExport["Ability Description"],
	"One Use Ability" : cardExport["One Use Ability"],
	"Should Remove" : cardExport["Should Remove"],
	"Hide Stats" : cardExport["Hide Stats"],
	"Is Human" : cardExport["Is Human"],
	"Has Hands" : cardExport["Has Hands"]
	}
	return daExport
