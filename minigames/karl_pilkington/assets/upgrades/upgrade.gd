extends Sprite2D

enum names{
	HP,
	SPEED,
	SIZE,
	ATTACK
}

@export var state: names = names.HP

func _ready():
	position_calculation()

func position_calculation():
	global_position = Vector2(global.rng.randi_range(0 + 50, 1280 - 50), global.rng.randi_range(0 + 50, 720 - 50))


func _on_hitbox_area_entered(area):
	pass # Replace with function body.
