extends Node2D

@onready var mouseWindow = $MouseWindow

@onready var hyena = $Hyena
@onready var counter = $"Hyena Counter"
@onready var cpsCounter = $"CPS Counter"
@onready var hpsCounter = $"HPS Counter"
@onready var shopButton = $ShopButton
@onready var shopMenu = $ShopMenu
@onready var upgradeContainer = $"ShopMenu/Upgrade Container/VBoxContainer"

@onready var snackButton = $"ShopMenu/IdleContainer/VBoxContainer/Snack Button"
@onready var netButton = $"ShopMenu/IdleContainer/VBoxContainer/Net Button"
@onready var trapButton = $"ShopMenu/IdleContainer/VBoxContainer/Trap Button"
@onready var droneButton = $"ShopMenu/IdleContainer/VBoxContainer/Drone Button"
@onready var meatButton = $"ShopMenu/IdleContainer/VBoxContainer/Meat Button"
@onready var enclosureButton = $"ShopMenu/IdleContainer/VBoxContainer/Enclosure Button"
@onready var zooButton = $"ShopMenu/IdleContainer/VBoxContainer/Zoo Button"
@onready var sanctuaryButton = $"ShopMenu/IdleContainer/VBoxContainer/Sanctuary Button"

@onready var musicPlayer = $Music

var curClick:int = 0
@onready var clickUpgradePaths = [
	$"ShopMenu/Upgrade Container/VBoxContainer/Hyena Novice",
	$"ShopMenu/Upgrade Container/VBoxContainer/Hyena Beginner",
	$"ShopMenu/Upgrade Container/VBoxContainer/Hyena Casual",
	$"ShopMenu/Upgrade Container/VBoxContainer/Hyena Proficient",
	$"ShopMenu/Upgrade Container/VBoxContainer/Hyena Expert",
	$"ShopMenu/Upgrade Container/VBoxContainer/Hyena Master",
	$"ShopMenu/Upgrade Container/VBoxContainer/Hyena God"
]

var snackUpgrades:Dictionary = {
	"Natural Ingredients": false,
	"Field Testing": false,
}

var counterScene = preload("res://minigames/hyena_clicker/Counter.tscn")

const SAVE_PATH: String = "user://hyena.save"

const FLOAT_MIN = 1.79769e-308

var rng = RandomNumberGenerator.new()

var can_click:bool = false

var hyena_rotation:int = 8

var hyenas:Big = Big.new(0)

var snacks:int = 0
var traps:int = 0
var drones:int = 0
var enclosures:int = 0
var zoos:int = 0
var sanctuaries:int = 0

var nets:int = 0
var meat:int = 0
var encyclopedias:int = 0 

var HPS:Big = Big.new(0)

const MAX_IDLE:int = 1
var idle_timer:float = 3
var idle_loop:int = 1

const maxCPSTimer = 2
var cpsTimer = maxCPSTimer
var cpsData = 0

var easter_egg_timer:float = rng.randf_range(80,100)
var first_opened:bool = true

var trackList = [
	"res://minigames/hyena_clicker/music/Lets Get Together Now!.ogg",
	"res://minigames/hyena_clicker/music/Bargain Bin Boys.ogg"
]

func _ready():
	load_save()
	hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	
	if first_opened:
		play_specific_song(0)
		first_opened = false
		save()
	else:
		play_random_song()
	shopMenu.visible = false
	
	for upgrade in upgradeContainer.get_children():
		upgrade.pressed.connect(on_upgrade_pressed.bind(upgrade))
		upgrade.visible = false
	
	update_counter()
	update_yena()
	check_upgrade_availabiliy()
	get_tree().call_group("hyena buttons", "update_price")

func _process(delta):
	easter_egg_timer -= delta
	if easter_egg_timer <= 0:
		spawn_easter_egg()
		easter_egg_timer = rng.randf_range(80,100)
	
	cpsTimer -= delta
	if cpsTimer <= 0:
		get_CPS(cpsData)
		cpsData = 0
		cpsTimer = maxCPSTimer
	
	if hyena.rotation_degrees <= -15:
		hyena_rotation = +8
	elif hyena.rotation_degrees >= 15:
		hyena_rotation = -8
	hyena.rotation_degrees += hyena_rotation * delta
	hyena.scale = hyena.scale.lerp(Vector2(1, 1), delta * 5)
	
	idle_timer -= delta
	#print("TIMER: " + str(idle_timer))
	if idle_timer <= 0:
		idle_timer = MAX_IDLE
		add_hyenas(false)
		idle_loop += 1
		if idle_loop > 10:
			idle_loop = 1

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click") && can_click:
		click()
	if Input.is_action_just_pressed("back"):
		Transition.change_scene_to_file("res://world/main_world.tscn")

func get_CPS(clicks):
	var result:float = clicks / maxCPSTimer
	cpsCounter.text = str(result) + " CLICKS PER SECOND"

func update_HPS():
	hpsCounter.text = HPS.toString() + " HYENAS PER SECOND"

func click():
	add_hyenas(true)
	$Click.play()
	hyena.scale = Vector2(1.1, 1.1)
	cpsData += 1
	
	var instance = counterScene.instantiate()
	instance.move(hyena_calculation().toString())
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
	if (hyenas.isLargerThanOrEqualTo(1000000)):
		counter.text = hyenas.toAmericanName().to_upper() + " HYENAS "
	else:
		counter.text = hyenas.toString() + " HYENAS "

func update_yena():
	if hyenaInRange(0,999):
		$HyenaPlayer.play('stage 1')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenaInRange(1000, 4999):
		$HyenaPlayer.play('stage 2')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenaInRange(5000,49999):
		$HyenaPlayer.play('stage 3')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenaInRange(50000, 999999):
		$HyenaPlayer.play('stage 3')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
func hyenaInRange(val1:int, val2:int):
	if hyenas.isLargerThanOrEqualTo(val1) and hyenas.isLessThan(val2):
		return true
	else:
		return false

func hyena_calculation():
	var hyena_num:Big = Big.new(1)
	if curClick > 0:
		hyena_num.multiply(2 * (curClick))
	return hyena_num

func idle_calculation():
	var hyena_num:Big = Big.new(0)
	if idle_loop == 10:
		hyena_num.plus(snacks)
	hyena_num.plus(traps)
	hyena_num.plus(nets * 3)
	hyena_num.plus(drones * 7)
	hyena_num.plus(meat * 12)
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
	var hyenaString = hyenas.toString()
	var snackString = snackButton.bigPrice.toString()
	var netString = netButton.bigPrice.toString()
	var trapString = trapButton.bigPrice.toString()
	var droneString = droneButton.bigPrice.toString()
	var meatString = meatButton.bigPrice.toString()
	var enclosureString = enclosureButton.bigPrice.toString()
	var zooString = zooButton.bigPrice.toString()
	var sanctuaryString = sanctuaryButton.bigPrice.toString()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"FirstTime": first_opened,
		"Hyenas": hyenaString,
		"Snacks": snacks,
		"Snack Price": snackString,
		"Nets": nets,
		"Net Price": netString,
		"Traps": traps,
		"Trap Price": trapString,
		"Drones": drones,
		"Drone Price": droneString,
		"Meat": meat,
		"Meat Price": meatString,
		"Enclosures": enclosures,
		"Enclosure Price": enclosureString,
		"Zoos": zoos,
		"Zoo Price": zooString,
		"Sanctuaries": sanctuaries,
		"Sanctuary Price": sanctuaryString,
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
				hyenas = Big.new(current_line["Hyenas"])
				snacks = current_line["Snacks"]
				snackButton.bigPrice = Big.new(current_line["Snack Price"])
				nets = current_line["Nets"]
				netButton.bigPrice = Big.new(current_line["Net Price"])
				traps = current_line["Traps"]
				trapButton.bigPrice = Big.new(current_line["Trap Price"])
				drones = current_line["Drones"]
				droneButton.bigPrice = Big.new(current_line["Drone Price"])
				meat = current_line["Meat"]
				meatButton.bigPrice = Big.new(current_line["Meat Price"])
				enclosures = current_line["Enclosures"]
				enclosureButton.bigPrice = Big.new(current_line["Enclosure Price"])
				zoos = current_line["Zoos"]
				zooButton.bigPrice = Big.new(current_line["Zoo Price"])
				sanctuaries = current_line["Sanctuaries"]
				sanctuaryButton.bigPrice = Big.new(current_line["Sanctuary Price"])
				#upgrades = current_line["Upgrades"]
	HPS.plus(snacks * 0.1)
	HPS.plus(traps * 1)
	HPS.plus(meat * 10)
	update_HPS()

func _on_shop_button_pressed():
	print('whar')
	can_click = false
	if (shopMenu.visible == false):
		print('guh')
		shopMenu.visible = true
	elif (shopMenu.visible == true):
		shopMenu.visible = false
func on_item_button_clicked(button):
	if hyenas.isLargerThanOrEqualTo(button.bigPrice):
		remove_hyenas(button.bigPrice)
		button.multiply_price(button.price_multiplier)
		button.update_price()
		
		$KaChing.play()
		
		match (button.item):
			"HYENA SNACK":
				snacks += 1
				HPS.plus(0.1)
			"HYENA NET":
				nets += 1
				HPS.plus(1)
			"HYENA TRAP":
				traps += 1
			"HYENA DRONE":
				drones += 1
			"HYENA MEAT":
				meat += 1
				HPS.plus(10)
		update_HPS()
func on_upgrade_pressed(button):
	if hyenas.isLargerThanOrEqualTo(button.bigPrice):
		remove_hyenas(button.bigPrice)
		match button.line:
			"Click":
				curClick += 1
		check_upgrade_availabiliy()
		
		$KaChing.play()

func check_upgrade_availabiliy():
	for i in clickUpgradePaths.size():
		if i == curClick:
			clickUpgradePaths[i].visible = true
		else:
			clickUpgradePaths[i].visible = false

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
