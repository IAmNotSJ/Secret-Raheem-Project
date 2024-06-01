extends EnemyBase

@onready var shootingMarker = $ShootingMarker

@onready var curSpot:Vector2 = global_position

const bulletScene = preload("res://minigames/karl_pilkington/assets/enemies/carl pilkington/bullet/bullet.tscn")

enum movementTypes {
	SURROUND, # Just will be in like a circular motion around pilkington
	AVOID, # Choose a direction, dash to start, and then continually walk away from pilkington while maybe skewing to a direction until hits a wall. 
	RHINO # State like SURROUND, but has a rhino dash. Main difference is that carl cannot dash before the charge time. 
}

# Only used for debugging
var movementTypeNames = ["SURROUND", "AVOID", "RHINO"]

var curMovement = movementTypes.SURROUND

const speed = 9
var movement_angle:float = 50
#true = POSITIVE, false = NEGATIVE
var movement_angle_grow_direction:bool = true
var movement_angle_grow_speed:float = 10
var movement_gap:float = 150

var random_offset:Vector2i = Vector2i(rng.randi_range(-30, 30), rng.randi_range(-30, 30))

var moving:bool = true : 
	set(value):
		if value == true:
			$AnimationPlayer.play('run')
		if value == false:
			$AnimationPlayer.play('idle')

#Precision of shot, in degrees.
#When a shot occurs, number between -precision and precision will be added to the shot angle to pilkington. 
var precision:float = 4

#Initial phase duration
var dash_timer = 5

const RHINO_TIMER = 7
var rhino_timer = RHINO_TIMER

const RHINO_COOLDOWN = 3
#Really shouldn't be necessary but using moving instead of this isn't working for some bullshit fuckass bitch mother fucking reason. 
var rhino_cooldown = false


var shooting:bool = false

const max_shooting_timer = 0.6
var shooting_timer = max_shooting_timer

var shooting_cooldown = 0

func _ready():
	super()
	$RandomTimer.start()
	$"RhinoPath".target = target

func _process(delta):
	if shooting:
		if !shooting_cooldown > 0:
			shooting_timer -= delta
			if shooting_timer <= 0:
				shooting_timer = max_shooting_timer
				shoot()
		else:
			shooting_cooldown -= delta
	
	if !$attackPlayer.is_playing() and moving and !rhino_cooldown:
		move(delta)

func shoot():
	var direction = target.global_position - global_position
	var angleTo = rad_to_deg($ShootingMarker.transform.x.angle_to(direction))
	spawn_bullet(bulletScene.instantiate(), shootingMarker.global_position, angleTo + rng.randf_range(-precision, precision))

## MOVEMENT SHIT YO

func move(delta):
	match curMovement:
		movementTypes.SURROUND:
			dash_timer -= delta
			if dash_timer <= 0:
				changeMovement()
		movementTypes.RHINO:
			rhino_timer -= delta
			$RhinoPath.color.a = (RHINO_TIMER - rhino_timer) / RHINO_TIMER
			if rhino_timer <= 0:
				rhino_timer = RHINO_TIMER
				rhino_dash()
		movementTypes.AVOID:
			movement_gap += 30 * delta
			movement_angle += PI / 8 * delta
			dash_timer -= delta
			if dash_timer <= 0:
				changeMovement()
			if movement_gap >= 300:
				movement_gap = 300
	var intended_position = Vector2(target.global_position.x + cos(movement_angle) * movement_gap + random_offset.x, target.global_position.y + sin(movement_angle) * movement_gap + random_offset.y)
	global_position = global_position.lerp(intended_position, speed * delta)
	
	if movement_angle_grow_direction:
		movement_angle += movement_angle_grow_speed * delta
	else:
		movement_angle -= movement_angle_grow_speed * delta
	
	if curMovement == movementTypes.SURROUND:
		if global_position.x >= 1280 - 30 or global_position.x <= 0 + 30 or global_position.y >= 720 - 30 or global_position.y <= 0 + 30:
			changeMovement()
		
	position.x = clamp(position.x, -400, 1680)
	position.y = clamp(position.y, -400, 1120)

func changeMovement():
	match curMovement:
		movementTypes.SURROUND:
			movement_angle_grow_speed = rng.randi_range(2, 4)
			curMovement = movementTypes.AVOID
			movement_gap = 150
			shooting = true
		movementTypes.AVOID:
			curMovement = movementTypes.RHINO
			movement_angle_grow_speed = rng.randi_range(1, 3)
			movement_gap = rng.randi_range(300, 400)
			shooting = false
		movementTypes.RHINO:
			curMovement = movementTypes.SURROUND
			movement_angle_grow_speed = rng.randi_range(1, 3)
			movement_gap = rng.randi_range(100, 150) 
			shooting = true
	
	if rng.randi_range(1,2) % 2:
		movement_angle_grow_direction = true
	else:
		movement_angle_grow_direction = false
	
	movement_angle = recalculateAngle()
	dash()
	
	print('switching movement to ' + movementTypeNames[curMovement])

func dash(strength = 20):
	print('dashed!')
	moving = true
	modulate.a = 0.4
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x + cos(movement_angle) * strength, position.y + sin(movement_angle) * strength), 0.4)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1, 0.4)
	
	match curMovement:
		movementTypes.SURROUND:
			dash_timer = rng.randi_range(3,5)
			movement_gap += rng.randi_range(50, 75)
		movementTypes.AVOID:
			dash_timer = rng.randi_range(16,25)
	
	shooting_cooldown = 3

func rhino_dash(strength = 500):
	$RhinoPath.color.a = 0
	shooting = false
	
	var direction = target.global_position - global_position
	var angleTo = $ShootingMarker.transform.x.angle_to(direction)
	
	hurtbox_toggle()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x + cos(angleTo) * strength, position.y + sin(angleTo) * strength), 0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(self.hurtbox_toggle)
	
	rhino_cooldown = true
	
	$RhinoCooldown.start()

func recalculateAngle():
	var quadrant = 0
	if global_position.x >= 1280/2:
		# on the RIGHT side of the screen
		quadrant += 2
	else:
		quadrant -= 2
	if global_position.y >= 720/2:
		#on the TOP side of the screen
		quadrant += 1
	else:
		quadrant -= 1
	return (rng.randf_range(PI/2 * quadrant - PI/2, PI/2 * quadrant))


func _on_hurtbox_area_entered(area):
	area.get_parent().get_parent().hit()

#bitch
func hurtbox_toggle():
	if $Hurtbox.monitoring:
		$Hurtbox.monitoring = false
	else:
		$Hurtbox.monitoring = true


func _on_rhino_cooldown_timeout():
	rhino_cooldown = false
	shooting = true
	changeMovement()
	$RhinoCooldown.wait_time = RHINO_COOLDOWN


func _on_random_timer_timeout():
	print('timer out!')
	random_offset = Vector2i(rng.randi_range(-30, 30), rng.randi_range(-30, 30))
