class_name EnemyBullet extends EnemyAttack

@export var screenNotifier = VisibleOnScreenNotifier2D
@export var moving:bool = true
@export var toPos:bool = false
var final_pos:Vector2 = Vector2.ZERO


# Angle that the bullet will move in, in degrees
var angle:float = 0

func initialize(daAngle:float):
	angle = daAngle

func _ready():
	if screenNotifier != null:
		screenNotifier.screen_exited.connect(on_screen_exited)

func _process(delta):
	if moving:
		if !toPos:
			move_from_angle(delta)
		else:
			position = position.move_toward(final_pos, delta * speed)
	super(delta)

func move_from_angle(delta):
	position.x += speed * cos(deg_to_rad(angle)) * delta
	position.y += speed * sin(deg_to_rad(angle)) * delta

func on_screen_exited():
	destroy()
