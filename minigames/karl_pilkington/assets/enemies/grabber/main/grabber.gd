extends EnemyBase

var junkScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/junk/junk projectile.tscn")
var bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/grabber/bullet/bullet.tscn")

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
	
	for i in hands.size():
		hands[i].target = target
	
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
			for i in hands.size():
				hands[i].clap_attack(delta)
			if hands[0].clapCount == 3 and hands_reset():
				state = IDLE
				for i in hands.size():
					hands[i].clapCount = 0
		GRAB:
			if !$AttackPlayer.is_playing():
				state = IDLE
		SHOOT:
			hands[0].gun_attack(delta)
			if hands[0].is_reset():
				state = IDLE

func hands_reset():
	if hands[0].is_reset() and hands[1].is_reset():
		return true
	else:
		return false

func change_hands(anim:String = '', hand:int = 0):
	if anim != '':
		if hand == 0 or hand == 1:
			hands[0].change_hand(anim)
		if hand == 0 or hand == 2:
			hands[1].change_hand(anim)

func change_expression(expression:String = ''):
	if expression != '':
		$ExpressionChanger.play(expression)

func die():
	$IntroPlayer.play('dead')
	super()

func hurt(damage):
	change_expression('hit')
	super(damage)
