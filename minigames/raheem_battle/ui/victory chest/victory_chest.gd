extends Node2D

@onready var animation = $chest_animations
@export var wait_time = 1

@onready var turn = %turn
@onready var side = %side

func play():
	animation.play('open')
	await get_tree().create_timer(wait_time).timeout
	animation.play('close')

func bop():
	$text_animations.play('bop')
