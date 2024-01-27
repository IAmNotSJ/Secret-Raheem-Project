extends CanvasLayer

@onready var animationPlayer = $AnimationPlayer
var sceneTransitions:Dictionary = {
	"Overworld": preload("res://world/main/main_world.tscn"),
	"Cleft House": preload("res://world/key house/key_house.tscn"),
	"Cost House": preload("res://world/apartment/apartment.tscn"),
	"Pilkington": preload("res://minigames/karl_pilkington/pilkFull.tscn"),
	"Hyena": preload("res://minigames/hyena_clicker/hyena_clicker.tscn"),
	"Main Menu": preload("res://menu/main_menu.tscn")
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
		get_tree().change_scene_to_packed(sceneTransitions[target])
		animationPlayer.play('trans_back')
	else:
		get_tree().change_scene_to_packed(sceneTransitions[target])
