extends Control

const card_scene = preload("res://minigames/raheem_battle/cards/card.tscn")
@onready var flash_player = $flash_player

var card
var cur_upgrade

func _ready():
	cur_upgrade = Saves.battle_stats["Hyena Upgrades"]
func _on_x_pressed():
	visible = false

func generate_card():
	if is_instance_valid(card):
		card.queue_free()
	card = card_scene.instantiate()
	card.stats = card.return_stats_from_resource("res://minigames/raheem_battle/cards/card_variants/stats/021.tres")
	card.is_preview = true
	var upgradeAttack = ceil(float(cur_upgrade) / 2)
	var upgradeDefense = floor(float(cur_upgrade) / 2)
	
	card.stats["Base Attack"] = upgradeAttack
	card.stats["Base Defense"] = upgradeDefense
	
	$card.add_child(card)
