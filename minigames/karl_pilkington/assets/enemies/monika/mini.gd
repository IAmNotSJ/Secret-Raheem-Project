extends Sprite2D

const sporeScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/spore.tscn")
@export var health = 1

const MAX_SPORE_TIMER = 2
var spore_timer = MAX_SPORE_TIMER

var target

func _process(delta):
	spore_timer -= delta
	if spore_timer <= 0:
		spore_timer = MAX_SPORE_TIMER
		spawn_spore()

func spawn_spore():
	var spore = sporeScene.instantiate()
	var direction = target.global_position - global_position
	var angleTo = $Marker2D.transform.x.angle_to(direction)
	spore.angle = angleTo
	spore.global_position = $Marker2D.global_position
	get_tree().root.get_node("KarlPilkington").call_deferred("add_child", spore)


func _on_area_2d_area_entered(area):
	health -= area.owner.damage
	if health <= 0:
		queue_free()
