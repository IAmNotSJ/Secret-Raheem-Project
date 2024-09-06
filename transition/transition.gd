extends CanvasLayer


@onready var animationPlayer = $AnimationPlayer
var sceneTransitions:Dictionary = {
	"Overworld": "res://overworld/world/areas/raheemPlaza/main/main_world.tscn",
	"Cleft House": "res://overworld/world/areas/raheemPlaza/key house/key_house.tscn",
	"Cost House": "res://overworld/world/areas/raheemPlaza/apartment/apartment.tscn",
	"Pizzeria": "res://overworld/world/areas/raheemPlaza/pizzeria/pizzeria_back.tscn",
	"Pilkington": "res://minigames/karl_pilkington/pilkFull.tscn",
	"Hyena": "res://minigames/hyena_clicker/hyena_clicker.tscn",
	"Fishing": "res://minigames/fishing/fishing_minigame.tscn",
	"Paint": "res://minigames/paint/main/raheem_paint.tscn",
	"Main Menu": "res://menus/main/main_menu.tscn",
	"Battle": "res://minigames/raheem_battle/manager/raheem_battle.tscn"
}
func change_scene_to_file(target: String, money:int = 0) -> void:
	animationPlayer.play('trans')
	if money != 0:
		Saves.playerInfo["Copper Coins"] += money
		Saves.save(Saves.SaveTypes.SETTINGS)
	await(animationPlayer.animation_finished)
	global.sceneManager.changeScene(target)
	animationPlayer.play('trans_back')

func change_scene_to_preset(target: String, useTrans:bool = true, money:int = 0) -> void:
	if useTrans:
		animationPlayer.play('trans')
		await(animationPlayer.animation_finished)
		global.sceneManager.changeScene(sceneTransitions[target])
		if money != 0:
			Saves.playerInfo["Copper Coins"] += money
			Saves.save(Saves.SaveTypes.SETTINGS)
		animationPlayer.play('trans_back')
	else:
		global.sceneManager.changeScene(sceneTransitions[target])
		if money != 0:
			Saves.playerInfo["Copper Coins"] += money
			Saves.save(Saves.SaveTypes.SETTINGS)
