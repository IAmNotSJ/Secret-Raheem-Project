extends EnemyAttack

@onready var chef = global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").get_node("The Chef")

var target
var angle:float = 0

var timer = 16

func _process(delta):
	var direction = target.global_position - $Marker2D.global_position
	var angleTo = $Marker2D.transform.x.angle_to(direction)
	angle = angleTo
	rotation = angle
	
	timer -= delta
	if timer <= 0:
		modulate.a -= delta / 2
		if modulate.a <= 0:
			queue_free()
			chef.killOnDeath.erase(self)
	
	position.x += speed * cos(angle) * delta
	position.y += speed * sin(angle) * delta
	super(delta)
