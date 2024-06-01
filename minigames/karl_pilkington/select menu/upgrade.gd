class_name PilkUpgrade extends Control

@onready var parent = global.sceneManager.get_node("Pilkington")

var lightRotation:int = 20

var pilkingtonPath:String

var selected:bool = false

func _ready():
	var occluders = %PointLight2D.get_children()
	occluders.shuffle()
	for i in range(3):
		occluders[i].queue_free()
	%PointLight2D.rotation_degrees = global.rng.randi_range(0, 360)
	lightRotation = global.rng.randi_range(-40, 40)
func _process(delta):
	%PointLight2D.rotation_degrees += lightRotation * delta

func createUpgrade(daName, daDescription, path, daTexture):
	%Title.text = "[center]" + daName + "[/center]"
	%Description.text = "[center]" + daDescription + "[/center]"
	pilkingtonPath = path
	%UpgradeTexture.texture_normal = daTexture
func _on_upgrade_pressed():
	if !selected:
		parent.pilkPath = pilkingtonPath
		selected = true
		parent.changeScene("res://minigames/karl_pilkington/karl pilkington.tscn")

func change_scale(_scale:float = 1):
	%Scale.scale = Vector2(_scale, _scale)
