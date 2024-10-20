extends Label

@onready var ui = get_parent()

var show_stats:bool = false
var stats_timer = 0
var show_ability:bool = false
var ability_timer = 0

func _ready():
	ui.turn_ended.connect(_on_turn_finished)

func _on_turn_finished():
	if stats_timer > 0 and show_stats:
		stats_timer -= 1
		if stats_timer == 0:
			show_stats = false
		print("STATS TIMER: " + str(stats_timer))
	if ability_timer > 0 and show_ability:
		ability_timer -= 1
		if ability_timer == 0:
			show_ability = false
		print("ABILITY TIMER: " + str(ability_timer))

@rpc("any_peer")
func activate_text(exported_card):
	if show_stats:
		if show_ability:
			text = ui.game.get_opponent().player_name + " has chosen a card with " + str(exported_card["Attack"]) + " ATTACK and " + str(exported_card["Defense"]) + " DEFENSE and the ability " + exported_card["Ability"]
		else:
			text = ui.game.get_opponent().player_name + " has chosen a card with " + str(exported_card["Attack"]) + " ATTACK and " + str(exported_card["Defense"]) + " DEFENSE"
	else:
		if show_ability:
			text = ui.game.get_opponent().player_name + " has chosen a card with the ability " + exported_card["Ability"]
		else:
			text = ui.game.get_opponent().player_name + " has chosen their card."

@rpc("any_peer")
func set_status(daText:String):
	text = daText

@rpc("any_peer")
func clear():
	text = ""
