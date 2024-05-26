extends EnemyBase

enum {
	SMALL,
	TRANSITION,
	BIG,
	GROUNDED
}
var state = SMALL
@export var health2:int = 60

const eyeradius = 6

const miniScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/mini/mini.tscn")
const MAX_MINI_TIMER = Vector2(3, 5)
var miniTimer = rng.randf_range(MAX_MINI_TIMER.x, MAX_MINI_TIMER.y)

const bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/bullet/bullet.tscn")
const MAX_BULLET_TIMER = 8
var bulletTimer = MAX_BULLET_TIMER

const warnScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/warning/warning.tscn")
const MAX_WARN_TIMER = Vector2i(11, 20)
var warn_timer = rng.randi_range(MAX_WARN_TIMER.x, MAX_WARN_TIMER.y)

const deadFlowerScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/dead flower/dead_flower.tscn")
const MAX_DEAD_TIMER = Vector2i(10, 21)
var dead_timer = rng.randi_range(MAX_DEAD_TIMER.x, MAX_DEAD_TIMER.y)
var deadFlowerPositions = [[Vector2(225, 193), Vector2(-225, 193)], [Vector2(1055, 193), Vector2(1554, 193)]]

const flumpScene = preload("res://minigames/karl_pilkington/assets/enemies/monika/flump/flump.tscn")

func _ready():
	mainScene.music.stop() 
	super()

func _process(delta):
	look_at_target(target, $Sprite2D/Eye, $Sprite2D/Marker2D)
	match state:
		SMALL:
			bulletTimer -= delta
			if bulletTimer <= 0:
				bulletTimer = MAX_BULLET_TIMER
				shoot()
		BIG:
			miniTimer -= delta
			if miniTimer <= 0:
				miniTimer = rng.randf_range(MAX_MINI_TIMER.x, MAX_MINI_TIMER.y)
				spawn_mini()
			warn_timer -= delta
			if warn_timer <= 0:
				print('warn spawned!')
				warn_timer = rng.randi_range(MAX_WARN_TIMER.x, MAX_WARN_TIMER.y)
				spawn_warn()
			dead_timer -= delta
			if dead_timer <= 0:
				dead_timer = rng.randi_range(MAX_DEAD_TIMER.x, MAX_DEAD_TIMER.y)
				spawn_dead()
			if health <= 30:
				$ProgressionPlayer.play('ground')
				state = GROUNDED
				spawn_flump()
		GROUNDED:
			miniTimer -= delta * 2
			if miniTimer <= 0:
				miniTimer = rng.randf_range(MAX_MINI_TIMER.x, MAX_MINI_TIMER.y)
				spawn_mini()
			warn_timer -= delta * 5
			if warn_timer <= 0:
				warn_timer = rng.randi_range(MAX_WARN_TIMER.x, MAX_WARN_TIMER.y)
				spawn_warn()
			dead_timer -= delta
			if dead_timer <= 0:
				dead_timer = rng.randi_range(MAX_DEAD_TIMER.x, MAX_DEAD_TIMER.y)
				spawn_dead(true)
func hurt(damage):
	health -= damage
	if state == SMALL:
		if health <= 1:
			$ProgressionPlayer.play('change')
			mainScene.music.play() 
	else:
		#if state == BIG:
			#$Hitplayer.play('hurt big')
		if health <= 0:
			die()

func spawn_mini():
	var miniKa = miniScene.instantiate()
	miniKa.global_position = Vector2(randi_range(100, 1180), randi_range(200, 680))
	if miniKa.global_position.x < 1280 / 2:
		miniKa.flip_h = true
	miniKa.target = target
	killOnDeath.append(miniKa)
	mainScene.call_deferred("add_child", miniKa)

func spawn_warn():
	var warn = warnScene.instantiate()
	warn.global_position = target.global_position
	mainScene.call_deferred("add_child", warn)
func spawn_flump():
	var flump = flumpScene.instantiate()
	killOnDeath.append(flump)
	mainScene.call_deferred("add_child", flump)

func spawn_dead(ground:bool = false):
	if ground == false:
		var dead = deadFlowerScene.instantiate()
		deadFlowerPositions.shuffle()
		dead.global_position = deadFlowerPositions[0][1]
		dead.targetPos = deadFlowerPositions[0][0]
		mainScene.call_deferred("add_child", dead)
	else:
		for i in range(2):
			var dead = deadFlowerScene.instantiate()
			dead.global_position = deadFlowerPositions[i][1]
			dead.targetPos = deadFlowerPositions[i][0]
			mainScene.call_deferred("add_child", dead)

func shoot():
	var bullet = bulletScene.instantiate()
	if rng.randi_range(0,1) == 1:
		bullet.global_position = Vector2(rng.randi_range(50, 530), 150)
	else:
		bullet.global_position = Vector2(rng.randi_range(750, 1230), 150)
	var direction = target.global_position - bullet.global_position
	var angleTo = bullet.transform.x.angle_to(direction)
	bullet.spin = true
	bullet.angle = rad_to_deg(angleTo)
	mainScene.call_deferred("add_child", bullet)

func angleToTarget(daTarget, marker):
	var direction = daTarget.global_position - global_position
	var angleTo = marker.transform.x.angle_to(direction)
	return angleTo

func look_at_target(daTarget, pupil, marker):
	var angleTo = angleToTarget(daTarget, marker)
	pupil.position.x = eyeradius * cos(angleTo) + marker.position.x
	pupil.position.y = eyeradius * sin(angleTo) + marker.position.y

func change_health():
	health = health2
	mainScene.ui.update_max_health(health2)
	state = BIG

func die():
	$ProgressionPlayer.play('die')
	super()
