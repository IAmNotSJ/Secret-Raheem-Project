class_name PilkUpgrade extends Control

@onready var parent = get_tree().root.get_node("Pilkington")

var lightRotation:int = 20

var pilkingtonPath:String

func _ready():
	var occluders = $PointLight2D.get_children()
	occluders.shuffle()
	for i in range(3):
		occluders[i].queue_free()
	$PointLight2D.rotation_degrees = global.rng.randi_range(0, 360)
	lightRotation = global.rng.randi_range(-40, 40)
func _process(delta):
	$PointLight2D.rotation_degrees += lightRotation * delta

func createUpgrade(daName, daDescription, path, daTexture):
	$Title.text = "[center]" + daName + "[/center]"
	$Description.text = "[center]" + daDescription + "[/center]"
	pilkingtonPath = path
	$CenterContainer/Upgrade.texture_normal = daTexture
func _on_upgrade_pressed():
	parent.pilkPath = pilkingtonPath
	parent.changeScene("res://minigames/karl_pilkington/karl pilkington.tscn")