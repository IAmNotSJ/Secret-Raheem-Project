extends Sprite2D

@onready var monika = global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").get_node("Monika")

const sporeScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/bullet/bullet.tscn")
@export var health:float = 0.5

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
	spore.angle =  rad_to_deg(angleTo)
	spore.global_position = $Marker2D.global_position
	global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", spore)

func hurt(damage):
	health -= damage
	if health <= 0:
		monika.killOnDeath.erase(self)
		queue_free()


func _on_hitbox_area_entered(area):
	hurt(area.owner.damage)
