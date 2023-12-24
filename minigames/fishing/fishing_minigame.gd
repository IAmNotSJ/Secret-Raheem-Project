extends Node2D

@onready var animationPlayer = $Start/CleftPlayer
@onready var barPlayer = $Start/BarPlayer
@onready var bar = $Start/Bar
@onready var pointer = $Start/Bar/Fish

var rng:RandomNumberGenerator = RandomNumberGenerator.new()

var timer:float = 0

var stage:int = 0

var pointer_movement:float = 600

var keys = ["up", "right", "down", "left"]
var struggleArray = []

var fish = [['fish 1', .1], ['fish 2', .25], ['fish 3', .50], ['fish 4', .75], ['fish 5', .99]]

var cast_degree:int = 0

enum {
	WAIT,
	CAST,
	BAR,
	SELECTED,
	PRESHOOT,
	SHOOT,
	FALL,
	WATER,
	BITE,
	STRUGGLE,
	POSTINPUT,
	INPUT,
	CATCH
}
var state = WAIT

func _ready():
	bar.visible = false
	$Results.visible = false
	$Pond.visible = false
	$Cast.visible = false
	$Start.visible = true

func _physics_process(delta):
	#print (state)
	match state:
		WAIT:
			if Input.is_action_just_pressed("ui_accept"):
				animationPlayer.play("cast")
				await(animationPlayer.animation_finished)
				state = CAST
				print('switching to cast')
		CAST:
			bar.visible = true
			barPlayer.play("come in")
			animationPlayer.play('shake')
			await(barPlayer.animation_finished)
			barPlayer.play("shake")
			pointer_movement = 600
			state = BAR
		BAR:
			pointer.position.x += pointer_movement * delta
			if pointer.position.x > 235:
				pointer_movement = -pointer_movement
			elif pointer.position.x < -235:
				pointer_movement = -pointer_movement
			if Input.is_action_just_pressed("ui_accept"):
				state = SELECTED
				print('switching to selected')
		SELECTED:
			pointer_movement = lerpf(pointer_movement, 0, delta * 5)
			pointer.position.x += pointer_movement * delta
			if pointer.position.x > 235:
				pointer_movement = -pointer_movement
			elif pointer.position.x < -235:
				pointer_movement = -pointer_movement
			print(pointer_movement)
			if pointer_movement < 1 and pointer_movement > -1:
				pointer_movement = 0
				cast_degree = getCastDegree(pointer.position.x)
				print('stoppped')
				timer = 1.5
				state = PRESHOOT
				print('switching to preshoot')
		PRESHOOT:
			timer -= delta
			if timer <= 0:
				bar.visible = false
				animationPlayer.play("shoot")
				state = SHOOT
				print('switching to shoot')
		SHOOT:
			await animationPlayer.animation_finished
			$Start.visible = false
			$Cast.visible = true
			$Cast/AnimationPlayer.play("zoom")
			$Cast/BlurPlayer.play("zoom")
			state = FALL
			timer = 7
			print('switching to fall')
		FALL:
			timer -= delta
			if timer <= 0:
				$Cast.visible = false
				$Pond.visible = true
				$FlashPlayer.play('flash')
				$Pond/AnimationPlayer.play('bob')
				state = WATER
				timer = rng.randf_range(5, 20)
				print('switching to water')
		WATER:
			timer -= delta
			if timer <= 0:
				$Pond/EffectsPlayer.play('bite')
				state = STRUGGLE
				$Pond/AnimationPlayer.stop()
				timer = 2
				print('switching to struggle')
		STRUGGLE:
			timer -= delta
			if timer <= 0:
				$Pond/Exclamation.visible = false
				$Pond/AnimationPlayer.play('struggle')
				if (struggleArray == []):
					struggleArray = makeArrowArray()
					$Pond/Arrow.rotation_degrees = makeArrowDegrees()
					$Pond/Arrow.playAnim('scale')
					$Pond/Arrow.visible = true
					print(struggleArray)
				state = INPUT
		INPUT:
			if struggleArray == []:
				state = POSTINPUT
				timer = 1
				print('switching to postinput')
		POSTINPUT:
			timer -= delta
			if timer <= 0:
				$FlashPlayer.play('flash')
				print("FUCKING FISH:" + getFishCatch())
				$Pond.visible = false
				$Results.visible = true
				state = CATCH
				print('switching to catch')
		CATCH:
			if Input.is_action_just_pressed("ui_accept"):
				state = WAIT
				$Results.visible = false
				$Start.visible = true
				animationPlayer.play('RESET')
				print('switching to catch')

func _unhandled_input(event):
	if (state == INPUT):
		if Input.is_action_just_pressed(struggleArray[0]):
			struggleArray.remove_at(0)
			if (struggleArray != []):
				$Pond/Arrow.rotation_degrees = makeArrowDegrees()
				$Pond/Arrow.playAnim('scale')
			else:
				$Pond/Arrow.visible = false
			print(struggleArray)
		elif !Input.is_action_just_pressed(struggleArray[0]) and Input.is_anything_pressed():
			struggleArray = makeArrowArray()
			$Pond/Arrow.rotation_degrees = makeArrowDegrees()
			$Pond/Arrow.playAnim('scale')
			print('restart! so sad!')
			print(struggleArray)

func makeArrowArray():
	var array = []
	for i in range(10):
		array.append(keys[rng.randi_range(0,3)])
	return array

func makeArrowDegrees():
	var degrees:float = 0
	
	var rotation_figure:int = 0
	
	match struggleArray[0]:
		'up':
			rotation_figure = 0
		'right':
			rotation_figure = 1
		'down':
			rotation_figure = 2
		'left':
			rotation_figure = 3
	
	degrees = 90 * rotation_figure
	return degrees

func getCastDegree(pos:int):
	var degree:int = 0
	if pos >= -235 and pos < -178 or pos > 178 and pos <= 235:
		degree = 0
	if pos >= -178 and pos < -113 or pos > 113 and pos <= 178:
		degree = 1
	if pos >= -113 and pos < -49 or pos > 49 and pos <= 113:
		degree = 2
	if pos >= -49 and pos < -11 or pos > 49 and pos <= 11:
		degree = 3
	if pos >= -11 and pos <= 11:
		degree = 4
	print ('DEGREE:' + str(degree))
	return degree

func getFishCatch():
	var fishName:String = ''
	
	fishName = fish[rng.randi_range(0, fish.size())][0]
	
	return fishName
	 
