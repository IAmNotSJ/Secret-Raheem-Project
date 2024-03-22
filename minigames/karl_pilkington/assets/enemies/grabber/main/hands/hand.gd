extends EnemyAttack

const bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/bullet/bullet.tscn")
const junkScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/junk/junk projectile.tscn")
var parent = get_parent()

const MAX_CLAP_TIMER = 3
var clap_timer = MAX_CLAP_TIMER
var clapState = 0
var clapCount = 0

const gun_hand_pos = Vector2(546, 189)
var gun_state = 0
const MAX_PREGUN_TIMER = 2
const MAX_GUN_TIMER = 5
var gun_timer = MAX_PREGUN_TIMER
const MAX_SHOOT_TIMER = 0.3
var shoot_timer = MAX_SHOOT_TIMER
var modifier = 1

var target

var posOffset:int = 1

func _ready():
	if flip_h:
		posOffset = -1
		$Marker2D.position.x *= -1
		$Hurtbox.position.x *= -1

func clap_attack(delta):
	if clapCount < 3:
		match clapState:
			0:
				clap_timer -= delta
				position = position.move_toward(Vector2(550 * posOffset, target.global_position.y + 75), delta * speed)
				if clap_timer <= 0:
					clapState = 1
					clap_timer = MAX_CLAP_TIMER
					change_hand('clap')
				
			1:
				position = position.move_toward(Vector2(0, position.y), delta * speed * 2)
				if position.x == 0:
					clapState = 2
					print('GUH')
					change_hand('prepped')
				
			2:
				position = position.move_toward(Vector2(473 * posOffset, position.y), delta * speed * 1.5)
				if position.x == 473 * posOffset:
					clapState = 0
					clapCount += 1
	else:
		reset(delta)
func gun_attack(delta):
	match gun_state:
		0:
			position = position.move_toward(Vector2(gun_hand_pos.x * posOffset, gun_hand_pos.y), delta * speed)
			if position == Vector2(gun_hand_pos.x * posOffset, gun_hand_pos.y):
				gun_state = 1
				change_hand('gun')
		1:
			gun_timer -= delta
			if gun_timer <= 0:
				gun_state = 2
				gun_timer = MAX_GUN_TIMER
		2:
			gun_timer -= delta
			if rotation_degrees >= 65:
				modifier = -1
			elif rotation_degrees <= -30:
				modifier = 1
			rotation_degrees += 25 * modifier * delta
			shoot_timer -= delta
			if shoot_timer <= 0:
				shoot()
				shoot_timer = MAX_SHOOT_TIMER
			if gun_timer <= 0:
				gun_state = 3
				gun_timer = MAX_PREGUN_TIMER
				change_hand('prepped')
		3:
			reset(delta)

func shoot():
	var bullet = bulletScene.instantiate()
	bullet.global_position = $Marker2D.global_position
	bullet.angle = rotation_degrees
	bullet.rotation_degrees = bullet.angle
	global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", bullet)
func spawn_junk():
	for i in range(-2, 3):
		var junk = junkScene.instantiate()
		var direction = target.global_position - $Marker2D.global_position
		var angleTo = $Marker2D.transform.x.angle_to(direction)
		junk.global_position = $Marker2D.global_position
		junk.angle = rad_to_deg(angleTo)  + i * 20
		global.sceneManager.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", junk)

func change_hand(anim:String = ''):
	if anim != '':
		$HandChanger.play(anim)
		$Marker2D.position.x *= posOffset
		$Hurtbox.position.x *= posOffset

func change_hurtbox(daPosition:Vector2):
	$Hurtbox.position = daPosition
	$Hurtbox.position.x *= posOffset

func change_marker(daPosition:Vector2):
	$Marker2D.position = daPosition
	$Marker2D.position.x *= posOffset

func reset(delta, extraSpeed = 1):
	position = position.move_toward(Vector2(473 * posOffset, 532), delta * speed * extraSpeed)

func is_reset():
	if position == Vector2(473 * posOffset, 532):
		return true
	else:
		return false
