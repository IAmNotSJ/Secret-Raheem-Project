class_name EnemyAttack extends Sprite2D

@export var hurtbox:Array[Area2D]
@export var destroyOnHit:bool = false

@export var speed:float = 1
@export var hurtboxDetection:bool = true
var velocity:Vector2 = Vector2.ZERO

func _process(_delta):
	if hurtbox != null:
		if hurtboxDetection:
			for i in hurtbox.size():
				if hurtbox[i].monitoring:
					if hurtbox[i].has_overlapping_areas():
						for area in hurtbox[i].get_overlapping_areas():
							area.get_parent().get_parent().hit()
							if destroyOnHit:
								destroy()

func move_and_slide(delta):
	position.x += speed * velocity.x * delta
	position.y += speed * velocity.y * delta

func destroy():
	queue_free()
