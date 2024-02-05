extends LegacyMember

@onready var bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/legacy/basic_bullet.tscn")
@onready var gasTexture = preload("res://minigames/karl_pilkington/assets/enemies/legacy/gas/gas_bullet.png")

@onready var pupil = $Pupil
@onready var marker = $Marker2D

var posArray:Array = [Vector2(309, 198), Vector2(1098, 198),Vector2(1095, 588), Vector2(309, 588)]

enum {
	OUT,
	IN,
	IDLE
}
var tpState = IDLE

const max_shoot = 0.5
var shoot_timer = max_shoot
var shootAmnt = 2

var firstSpawn = true

func _ready():
	posArray.shuffle()
	super()
func _process(delta):
	if active:
		look_at_target(target, pupil, marker)
		
		match tpState:
			IDLE:
				if !firstSpawn:
					shoot_timer-= delta
					if shoot_timer <= 0 and shootAmnt > 0:
						shoot_timer = max_shoot
						shoot()
			OUT:
				modulate.a -= delta * 2.5
			IN:
				modulate.a += delta * 2.5
				
				if modulate.a >= 1:
					firstSpawn = false
					tpState = IDLE
		
		attackTimer -= delta
		if attackTimer <= 0:
			attackTimer = ATTACK_TIMER
			shootAmnt = 2
			tpState = OUT
		if modulate.a <= 0:
			posArray.shuffle()
			while posArray[0] == position:
				posArray.shuffle()
			position = posArray[0]
			tpState = IN

func shoot():
	shootAmnt -= 1
	var bullet = bulletScene.instantiate()
	bullet.global_position = pupil.global_position
	var angleTo = angleToTarget(target, marker)
	bullet.start(rad_to_deg(angleTo), gasTexture, 600)
	mainScene.call_deferred("add_child", bullet)
