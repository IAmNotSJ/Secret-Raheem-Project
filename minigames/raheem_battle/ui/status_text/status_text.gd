extends Label

@onready var ui = get_parent()
@onready var anim = $anim

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
	if ability_timer > 0 and show_ability:
		ability_timer -= 1
		if ability_timer == 0:
			show_ability = false

@rpc("any_peer")
func activate_text(exported_card):
	if show_stats:
		if show_ability:
			set_status(ui.game.get_opponent().player_name + " has chosen a card with " + str(exported_card["True Attack"]) + " ATTACK and " + str(exported_card["True Defense"]) + " DEFENSE and the ability " + exported_card["Ability Name"])
		else:
			set_status(ui.game.get_opponent().player_name + " has chosen a card with " + str(exported_card["True Attack"]) + " ATTACK and " + str(exported_card["True Defense"]) + " DEFENSE")
	else:
		if show_ability:
			if exported_card["Ability Name"] == "":
				set_status(ui.game.get_opponent().player_name + " has chosen a card without an ability.")
			else:
				set_status(ui.game.get_opponent().player_name + " has chosen a card with the ability " + exported_card["Ability Name"])
		else:
			set_status(ui.game.get_opponent().player_name + " has chosen their card.")

@rpc("any_peer")
func set_status(daText:String):
	text = daText
	$anim.play('fade')

@rpc("any_peer")
func clear():
	text = ""
