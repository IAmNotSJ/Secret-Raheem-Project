extends EnemyBullet

@onready var anim = $AnimationPlayer

var rng = RandomNumberGenerator.new()

var rotation_gain = rng.randi_range(-40, 40)

func _ready():
	anim.play("Character " + str(rng.randi_range(1, 4)))
	super()

func _process(delta):
	rotation_degrees += rotation_gain * delta
	super(delta)
