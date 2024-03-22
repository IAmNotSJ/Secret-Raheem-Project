class_name Portrait extends Node2D

var curCharacter:String = ''
var curEmotion:String = ''

@onready var animationPlayer = $AnimationPlayer
@onready var introPlayer = $IntroPlayer

func _ready():
	visible = false

func change(character:String, emotion:String):
	print('changed')
	var finalAnim:String = ''
	if !visible or curCharacter != character:
		visible = true
		introPlayer.play('intro')
	finalAnim += character + ' '
	finalAnim += emotion
	
	animationPlayer.play(finalAnim)
