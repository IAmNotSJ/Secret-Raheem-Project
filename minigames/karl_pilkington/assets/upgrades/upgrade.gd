extends Sprite2D

var states:Dictionary = {
	"HP" : 0,
	"SPEED" : 15,
	"SIZE" : 10,
	"ATTACK" : 10
}
var state:String = "SPEED"

var cooldown:float = 10

func _ready():
	state = states.keys()[global.rng.randi_range(0, states.keys().size() - 1)]
	$AnimationPlayer.play(state)
	position_calculation()

func position_calculation():
	global_position = Vector2(global.rng.randi_range(0 + 50, 1280 - 50), global.rng.randi_range(0 + 50, 720 - 50))

func disable():
	visible = false
	$Hitbox.set_deferred("monitoring", false)
	$Hitbox.set_deferred("monitorable", false)

func _on_hitbox_area_entered(area):
	disable()
	if "stats" in area.get_parent().get_parent():
		area.get_parent().get_parent().add_upgrade(self)
	print('GUH')
