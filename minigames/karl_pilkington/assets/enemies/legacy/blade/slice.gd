extends Node2D

@export var hurtbox:Area2D

@onready var slice = $DaSlice
@onready var collisionShape = $Hurtbox/CollisionShape2D
@onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.play('slice')
func _process(_delta):
	if hurtbox.has_overlapping_areas():
		for area in hurtbox.get_overlapping_areas():
			area.get_parent().get_parent().hit()
	
	if !$AnimationPlayer.is_playing():
		queue_free()
