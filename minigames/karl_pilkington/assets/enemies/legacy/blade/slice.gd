extends Node2D

@onready var slice = $DaSlice
@onready var collisionShape = $Area2D/CollisionShape2D
@onready var animationPlayer = $AnimationPlayer

func _ready():
	animationPlayer.play('slice')
func _process(_delta):
	collisionShape.shape.size = slice.size
	collisionShape.global_position = slice.global_position
	
	if !$AnimationPlayer.is_playing():
		queue_free()

func _on_area_2d_area_entered(area):
	area.owner.hit()
