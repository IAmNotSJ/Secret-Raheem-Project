extends Sprite2D

@onready var anim = $AnimationPlayer

var rng = RandomNumberGenerator.new()

const speed = 550
var angle
var rotation_gain = rng.randi_range(-40, 40)

func _ready():
	anim.play("Character " + str(rng.randi_range(1, 4)))
	print(angle)

func _process(delta):
	position.x += -speed * cos(deg_to_rad(angle)) * delta
	position.y += speed * sin(deg_to_rad(angle)) * delta
	rotation_degrees += rotation_gain * delta


func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
