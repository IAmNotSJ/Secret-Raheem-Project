extends CanvasLayer

@onready var animationPlayer = $AnimationPlayer
var sceneTransitions:Dictionary = {
	"Overworld": "res://world/main/main_world.tscn",
	"Cleft House": "res://world/key house/key_house.tscn",
	"Cost House": "res://world/apartment/apartment.tscn",
	"Pilkington": "res://minigames/karl_pilkington/pilkFull.tscn",
	"Hyena": "res://minigames/hyena_clicker/hyena_clicker.tscn",
	"Main Menu": "res://menu/main_menu.tscn"
}
func change_scene_to_file(target: String) -> void:
	animationPlayer.play('trans')
	await(animationPlayer.animation_finished)
	get_tree().change_scene_to_file(target)
	animationPlayer.play('trans_back')

func change_scene_to_preset(target: String, useTrans:bool = true) -> void:
	if useTrans:
		animationPlayer.play('trans')
		await(animationPlayer.animation_finished)
		get_tree().change_scene_to_packed(load(sceneTransitions[target]))
		animationPlayer.play('trans_back')
	else:
		get_tree().change_scene_to_packed(load(sceneTransitions[target]))
