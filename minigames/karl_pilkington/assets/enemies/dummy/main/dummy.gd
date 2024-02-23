extends EnemyBase

const counterScene = preload("res://minigames/karl_pilkington/assets/enemies/dummy/counter/counter.tscn")

var canHold:bool = false

const MAX_HOLD:float = 0.25
var hold_timer:float = MAX_HOLD
var holding:bool = false

func _ready():
	teleport()
	super()

func _process(delta):
	if Input.is_action_pressed("click"):
		hold_timer -= delta
		if hold_timer <= 0:
			holding = true
			$EffectPlayer.play('grab')
			if target != null:
				target.canShoot = false
	if Input.is_action_just_released("click"):
		hold_timer = MAX_HOLD
		holding = false
		if target != null:
			target.canShoot = true
		$EffectPlayer.play('RESET')
	if holding:
		global_position = get_global_mouse_position() + Vector2(0, 20)

func hurt(damage:float):
	$AnimationPlayer.play('hurt')
	print('yeouch')
	var counter = counterScene.instantiate()
	counter.initialize(damage, global_position - Vector2(30, 150))
	mainScene.add_child(counter)

func teleport():
	if !holding:
		global_position = Vector2(global.rng.randi_range(50, 1230), global.rng.randi_range(30, 690))


func _on_control_focus_entered():
	print('brah')

func _on_control_focus_exited():
	print('brah!')
