extends PilkingtonBase

@onready var shield = $Picture
@onready var shieldMarker = $PaintingOffset
var shieldRadius = 80

func _ready():
	shield.pilkington = self

func _physics_process(delta):
	var dir = (get_global_mouse_position() - global_position).angle() + deg_to_rad(180)
	print(dir)
	shield.rotation = dir + deg_to_rad(90)
	shield.position.x = shieldRadius * cos(dir) + shieldMarker.position.x
	shield.position.y = shieldRadius * sin(dir) + shieldMarker.position.y
	super(delta)
