extends EnemyBase

var junkScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/junk projectile.tscn")
var bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/bullet.tscn")

var curEmotion = 'angry'

const MAX_ATTACK_TIMER = 1
var attack_timer = MAX_ATTACK_TIMER

const HAND_SPEED = 275
const MAX_CLAP_TIMER = 1
var clapCount = 0
var clap_timer = MAX_ATTACK_TIMER
var clapState = 0

const gun_hand_pos = Vector2(-546, 189)
var gun_state = 0
const MAX_PREGUN_TIMER = 2
const MAX_GUN_TIMER = 5
var gun_timer = MAX_PREGUN_TIMER
const MAX_SHOOT_TIMER = 0.3
var shoot_timer = MAX_SHOOT_TIMER
var modifier = 1

enum {
	IDLE,
	CLAP,
	GRAB,
	SHOOT
}
var state = IDLE

@onready var hands = [$Hand1, $Hand2]

func _ready():
	$IntroPlayer.play('intro')
	super()
func _process(delta):
	match state:
		IDLE:
			attack_timer -= delta
			print(attack_timer)
			if attack_timer <= 0:
				attack_timer = MAX_ATTACK_TIMER
				
				match rng.randi_range(0,2):
					0:
						state = CLAP
					1:
						state = GRAB
						$AttackPlayer.play("grab")
					2:
						state = SHOOT
		CLAP:
			clap_attack(delta)
		GRAB:
			if !$AttackPlayer.is_playing():
				state = IDLE
		SHOOT:
			gun_attack(delta)

func clap_attack(delta):
	if clapCount < 3:
		match clapState:
			0:
				clap_timer -= delta
				for i in hands.size():
					match i:
						0:
							hands[i].position = hands[i].position.move_toward(Vector2(-550, target.position.y + 75), delta * HAND_SPEED)
						1:
							hands[i].position = hands[i].position.move_toward(Vector2(550, target.position.y + 75), delta * HAND_SPEED)
				if clap_timer <= 0:
					clapState = 1
					clap_timer = MAX_CLAP_TIMER
					change_hands('clap')
			1:
				for i in hands.size():
					hands[i].position = hands[i].position.move_toward(Vector2(0, hands[i].position.y), delta * HAND_SPEED * 2)
					if hands[i].position.x == 0:
						clapState = 2
						change_hands('prepped')
			2:
				for i in hands.size():
					match i:
						0:
							hands[i].position = hands[i].position.move_toward(Vector2(-426, hands[i].position.y), delta * HAND_SPEED * 1.5)
						1:
							hands[i].position = hands[i].position.move_toward(Vector2(426, hands[i].position.y), delta * HAND_SPEED * 1.5)
					if hands[0].position.x == -426 and hands[1].position.x == 426:
						clapState = 0
						clapCount += 1
	else:
		reset_hands(delta)
		if hands_reset():
			state = IDLE
			clapCount = 0

func gun_attack(delta):
	match gun_state:
		0:
			hands[0].position = hands[0].position.move_toward(Vector2(gun_hand_pos), delta * HAND_SPEED)
			if hands[0].position == gun_hand_pos:
				gun_state = 1
				change_hands('gun', 1)
		1:
			gun_timer -= delta
			if gun_timer <= 0:
				gun_state = 2
				gun_timer = MAX_GUN_TIMER
		2:
			gun_timer -= delta
			if $Hand1/Hand1Sprite.rotation_degrees >= 65:
				modifier = -1
			elif $Hand1/Hand1Sprite.rotation_degrees <= -30:
				modifier = 1
			$Hand1/Hand1Sprite.rotation_degrees += 25 * modifier * delta
			shoot_timer -= delta
			if shoot_timer <= 0:
				shoot_hand_bullet()
				shoot_timer = MAX_SHOOT_TIMER
			if gun_timer <= 0:
				gun_state = 3
				gun_timer = MAX_PREGUN_TIMER
				change_hands('prepped', 0)
		3:
			reset_hands(delta)
			if hands_reset():
				state = IDLE

func reset_hands(delta):
	hands[0].position = hands[0].position.move_toward(Vector2(-473, 532), delta * HAND_SPEED)
	hands[1].position = hands[1].position.move_toward(Vector2(473, 532), delta * HAND_SPEED)

func hands_reset():
	if hands[0].position == Vector2(-473, 532) and hands[1].position == Vector2(473, 532):
		return true
	else:
		return false

func change_hands(anim:String = '', hand:int = 0):
	if anim != '':
		if hand == 0 or hand == 1:
			$Hand1Changer.play(anim)
		if hand == 0 or hand == 2:
			$Hand2Changer.play(anim)
func _on_hurtbox_area_entered(area):
	area.owner.hit()

func spawn_junk():
	for i in range(-2, 3):
		var junk = junkScene.instantiate()
		var direction = target.global_position - $Hand2/Marker2D.global_position
		var angleTo = $Hand2/Marker2D.transform.x.angle_to(direction) + i*15
		junk.global_position = $Hand2/Marker2D.global_position
		junk.angle = angleTo
		get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", junk)

func shoot_hand_bullet():
	var bullet = bulletScene.instantiate()
	bullet.global_position = $Hand1/Hand1Sprite/Marker2D.global_position
	bullet.angle = $Hand1/Hand1Sprite.rotation_degrees
	bullet.rotation_degrees = bullet.angle
	get_tree().root.get_node("Pilkington").get_node("KarlPilkington").call_deferred("add_child", bullet)

func change_expression(expression:String = ''):
	if expression != '':
		$ExpressionChanger.play(expression)

func die():
	$IntroPlayer.play('dead')
	super()

func hurt(damage):
	change_expression('hit')
	super(damage)
