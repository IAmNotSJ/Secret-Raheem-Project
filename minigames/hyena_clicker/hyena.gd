extends Node2D

@onready var hyena = $Hyena
@onready var counter = $Counter
@onready var shopButton = $ShopButton
@onready var shopMenu = $ShopMenu

@onready var netButton = $"ShopMenu/Net Button"
@onready var trapButton = $"ShopMenu/Trap Button"
@onready var droneButton = $"ShopMenu/Drone Button"
@onready var meatButton = $"ShopMenu/Meat Button"

@onready var musicPlayer = $Music


var counterScene = preload("res://minigames/hyena_clicker/misc/counter/counter.tscn")

const SAVE_PATH: String = "user://hyena.bin"

var rng = RandomNumberGenerator.new()

var can_click:bool = false

var hyena_rotation:int = 8

var hyenas:Big = Big.new(0)
var nets:int = 0
var traps:int = 0
var drones:int = 0
var meat:int = 0

var idle_timer:float = 3

var easter_egg_timer:float = rng.randf_range(80,100)
var first_opened:bool = true

var trackList = [
	"res://minigames/hyena_clicker/music/Lets Get Together Now!.ogg",
	"res://minigames/hyena_clicker/music/Bargain Bin Boys.ogg"
]

func _ready():
	load_save()
	
	if first_opened:
		play_specific_song(0)
		first_opened = false
		save()
	else:
		play_random_song()
	shopMenu.visible = false
	
	update_counter()
	update_yena()
	get_tree().call_group("hyena buttons", "update_price")

func _process(delta):
	easter_egg_timer -= delta
	if easter_egg_timer <= 0:
		spawn_easter_egg()
		easter_egg_timer = rng.randf_range(80,100)
	
	if hyena.rotation_degrees <= -15:
		hyena_rotation = +8
	elif hyena.rotation_degrees >= 15:
		hyena_rotation = -8
	hyena.rotation_degrees += hyena_rotation * delta
	hyena.scale = hyena.scale.lerp(Vector2(1, 1), delta * 5)
	
	if (traps > 0):
		idle_timer -= delta * traps
		#print("TIMER: " + str(idle_timer))
		if idle_timer <= 0:
			idle_timer = 3
			add_hyenas(false)
			

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click") && can_click:
		click()
	if Input.is_action_just_pressed("back"):
		Transition.change_scene_to_file("res://world/main_world.tscn")

func click():
	add_hyenas(true)
	hyena.scale = Vector2(1.1, 1.1)
	
	var instance = counterScene.instantiate()
	instance.move(hyena_calculation())
	instance.set_position(Vector2(get_global_mouse_position().x - 16, get_global_mouse_position().y - 25))
	add_child(instance)

func add_hyenas(isClick:bool = true):
	if (isClick):
		hyenas.plus(hyena_calculation())
	else:
		hyenas.plus(idle_calculation())
	save()
	update_counter()
	update_yena()

func remove_hyenas(amount):
	hyenas.minus(amount)
	save()
	update_counter()
	update_yena()

func update_counter():
	counter.text =  hyenas.toString() + " HYENAS "

func update_yena():
	if hyenas.isLargerThanOrEqualTo(0) and hyenas.isLessThanOrEqualTo(999):
		$HyenaPlayer.play('stage 1')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenas.isLargerThanOrEqualTo(1000) and hyenas.isLessThanOrEqualTo(4999):
		$HyenaPlayer.play('stage 2')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenas.isLargerThanOrEqualTo(5000) and hyenas.isLessThanOrEqualTo(49999):
		$HyenaPlayer.play('stage 3')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenas.isLargerThanOrEqualTo(50000) and hyenas.isLessThanOrEqualTo(999999):
		$HyenaPlayer.play('stage 3')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)

func hyena_calculation():
	var hyena_num:Big = Big.new(1)
	if (nets != 0):
		hyena_num.plus(nets)
	if (meat != 0):
		hyena_num.plus(meat * 5)
	return hyena_num

func idle_calculation():
	var hyena_num:Big = Big.new(1 * (drones + 1))
	return hyena_num

func spawn_easter_egg():
	match rng.randi_range(0, 1):
		0:
			$IdleAnims.play("creature_run")
			$TheCreature.position.x = 1300
			var tween = create_tween()
			tween.tween_property($TheCreature, "position", Vector2(-200, $TheCreature.position.y), 3)
		1:
			$IdleAnims.play("popup")

func _on_hyena_mouse_entered():
	can_click = true

func _on_hyena_mouse_exited():
	can_click = false

func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"FirstTime": first_opened,
		"Hyenas": hyenas,
		"Nets": nets,
		"Net Price": netButton.price,
		"Traps": traps,
		"Trap Price": trapButton.price,
		"Drones": drones,
		"Drone Price": droneButton.price,
		"Meat": meat,
		"Meat Price": meatButton.price
	}
	var jstr = JSON.stringify(data)
	
	file.store_line(jstr)
	print('saved!')

func load_save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print('poo no')
		return
	if file == null:
		print('poo null')
		return
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				first_opened = current_line["FirstTime"]
				hyenas = current_line["Hyenas"]
				nets = current_line["Nets"]
				netButton.price = current_line["Net Price"]
				traps = current_line["Traps"]
				trapButton.price = current_line["Trap Price"]
				drones = current_line["Drones"]
				droneButton.price = current_line["Drone Price"]
				meat = current_line["Meat"]
				meatButton.price = current_line["Meat Price"]

func _on_shop_button_pressed():
	print('whar')
	can_click = false
	if (shopMenu.visible == false):
		print('guh')
		shopMenu.visible = true
	elif (shopMenu.visible == true):
		shopMenu.visible = false


func on_item_button_clicked(button):
	if hyenas >= button.price:
		remove_hyenas(button.price)
		button.price *= button.price_multiplier
		print('net cost:' + str(button.price))
		button.update_price()
		
		$KaChing.play()
		
		match (button.item):
			"HYENA NET":
				nets += 1
			"HYENA TRAP":
				traps += 1
			"HYENA DRONE":
				drones += 1
			"HYENA MEAT":
				print('is this working'
				)
				meat += 1

func play_random_song():
	trackList.shuffle()
	musicPlayer.stream = load(trackList[0])
	var tween = create_tween()
	musicPlayer.volume_db = -80
	tween.tween_property(musicPlayer, "volume_db", 0, 1)
	
	musicPlayer.play()

func play_specific_song(song:int = 0):
	musicPlayer.stream = load(trackList[song])
	var tween = create_tween()
	musicPlayer.volume_db = -80
	tween.tween_property(musicPlayer, "volume_db", 0, 1)
	
	musicPlayer.play()

func _on_music_finished():
	play_random_song()
