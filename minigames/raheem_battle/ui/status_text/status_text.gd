extends Label

@onready var ui = get_parent()

var show_stats:bool = false
var stats_timer = 0

func _ready():
	ui.turn_ended.connect(_on_turn_finished)

func _on_turn_finished():
	if stats_timer > 0 and show_stats:
		stats_timer -= 1
		if stats_timer == 0:
			show_stats = false

@rpc("any_peer")
func activate_text(exported_card):
	if show_stats:
		text = ui.game.get_opponent().player_name + " has chosen a card with " + str(exported_card["Attack"]) + " ATTACK and " + str(exported_card["Defense"]) + " DEFENSE"
	else:
		text = ui.game.get_opponent().player_name + " has chosen their card."

@rpc("any_peer")
func clear():
	text = ""
