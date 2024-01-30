extends Node2D

@onready var mouseWindow = $MouseWindow

@onready var hyena = $Hyena
@onready var counter = $"Hyena Counter"
@onready var cpsCounter = $"CPS Counter"
@onready var hpsCounter = $"HPS Counter"
@onready var shopButton = $ShopButton
@onready var shopMenu = $ShopMenu

@onready var musicButton = $MusicLinkControl/MusicButton

@onready var netButton = $"ShopMenu/ClickContainer/VBoxContainer/Net Button"
@onready var meatButton = $"ShopMenu/ClickContainer/VBoxContainer/Meat Button"
@onready var encyclopediaButton = $"ShopMenu/ClickContainer/VBoxContainer/Encyclopedia Button"
@onready var callButton = $"ShopMenu/ClickContainer/VBoxContainer/Call Button"
@onready var tomeButton = $"ShopMenu/ClickContainer/VBoxContainer/Tome Button"
@onready var timeMachineButton = $"ShopMenu/ClickContainer/VBoxContainer/Time Machine Button"
@onready var armyButton = $"ShopMenu/ClickContainer/VBoxContainer/Army Button"
@onready var darkArtButton = $"ShopMenu/ClickContainer/VBoxContainer/Dark Art Button"
@onready var prismButton = $"ShopMenu/ClickContainer/VBoxContainer/Prism Button"
@onready var darkMatterButton = $"ShopMenu/ClickContainer/VBoxContainer/Dark Matter Button"
@onready var augmentorButton = $"ShopMenu/ClickContainer/VBoxContainer/Augmentor Button"
@onready var multiLevelQuantumManipulatorButton = $"ShopMenu/ClickContainer/VBoxContainer/MultiLevel Quantum Manipulator Button"
@onready var yenaforceButton = $"ShopMenu/ClickContainer/VBoxContainer/Yenaforce Button"
@onready var folderButton = $"ShopMenu/ClickContainer/VBoxContainer/Folder Button"
@onready var clickButtons = [netButton, meatButton, encyclopediaButton, callButton, tomeButton, timeMachineButton, armyButton, darkArtButton, prismButton, darkMatterButton, augmentorButton, multiLevelQuantumManipulatorButton, yenaforceButton, folderButton]

@onready var clickUpgrades:Dictionary = {
	"HYENA NET" : [0, netButton.bigPrice.toString()],
	"HYENA MEAT" : [0, meatButton.bigPrice.toString()],
	"HYENA ENCYCLOPEDIA" : [0, encyclopediaButton.bigPrice.toString()],
	"HYENA CALL" : [0, callButton.bigPrice.toString()],
	"HYENA TOME" : [0, tomeButton.bigPrice.toString()],
	"HYENA TIME MACHINE" : [0, timeMachineButton.bigPrice.toString()],
	"HYENA ARMY" : [0, armyButton.bigPrice.toString()],
	"HYENA DARK ARTS" : [0, darkArtButton.bigPrice.toString()],
	"HYENA PRISM" : [0, prismButton.bigPrice.toString()],
	"HYENA DARK MATTER" : [0, darkMatterButton.bigPrice.toString()],
	"HYENA AUGMENTOR" : [0, augmentorButton.bigPrice.toString()],
	"HYENA MULTILEVEL QUANTUM MANIPULATOR" : [0, multiLevelQuantumManipulatorButton.bigPrice.toString()],
	"HYENA FORCE" : [0, yenaforceButton.bigPrice.toString()],
	"HYENA FOLDER" : [0, folderButton.bigPrice.toString()],
}
var clickProduction:Dictionary = {
	"HYENA NET" : "1",
	"HYENA MEAT" : "3",
	"HYENA ENCYCLOPEDIA" : "8",
	"HYENA CALL" : "60",
	"HYENA TOME" : "420",
	"HYENA TIME MACHINE" : "28420",
	"HYENA ARMY" : "1.25e6",
	"HYENA DARK ARTS" : "6e6",
	"HYENA PRISM" : "3.3e8",
	"HYENA DARK MATTER" : "1.34e11",
	"HYENA AUGMENTOR" : "9.99e13",
	"HYENA MULTILEVEL QUANTUM MANIPULATOR" : "4.56e16",
	"HYENA FORCE" : "1e20",
	"HYENA FOLDER" : "9.99e23"
}
var curClick = 1

@onready var snackButton = $"ShopMenu/IdleContainer/VBoxContainer/Snack Button"
@onready var trapButton = $"ShopMenu/IdleContainer/VBoxContainer/Trap Button"
@onready var droneButton = $"ShopMenu/IdleContainer/VBoxContainer/Drone Button"
@onready var enclosureButton = $"ShopMenu/IdleContainer/VBoxContainer/Enclosure Button"
@onready var zooButton = $"ShopMenu/IdleContainer/VBoxContainer/Zoo Button"
@onready var sanctuaryButton = $"ShopMenu/IdleContainer/VBoxContainer/Sanctuary Button"
@onready var spellButton = $"ShopMenu/IdleContainer/VBoxContainer/Spell Button"
@onready var parkButton = $"ShopMenu/IdleContainer/VBoxContainer/Park Button"
@onready var rocketButton = $"ShopMenu/IdleContainer/VBoxContainer/Rocket Button"
@onready var colonyButton = $"ShopMenu/IdleContainer/VBoxContainer/Colony Button"
@onready var portalButton = $"ShopMenu/IdleContainer/VBoxContainer/Portal Button"
@onready var vortexButton = $"ShopMenu/IdleContainer/VBoxContainer/Vortex Button"
@onready var galaxyButton = $"ShopMenu/IdleContainer/VBoxContainer/Galaxy Button"
@onready var duplicatorButton = $"ShopMenu/IdleContainer/VBoxContainer/Duplicator Button"
@onready var dysonButton = $"ShopMenu/IdleContainer/VBoxContainer/Dyson Button"
@onready var blackHoleButton = $"ShopMenu/IdleContainer/VBoxContainer/Black Hole Button"
@onready var afterlifeButton = $"ShopMenu/IdleContainer/VBoxContainer/Afterlife Button"
@onready var singularityButton = $"ShopMenu/IdleContainer/VBoxContainer/Singularity Button"
@onready var universeButton = $"ShopMenu/IdleContainer/VBoxContainer/Universe Button"
@onready var multiverseButton = $"ShopMenu/IdleContainer/VBoxContainer/Multiverse Button"
@onready var idleButtons = [snackButton, trapButton, droneButton, enclosureButton, zooButton, parkButton,sanctuaryButton, spellButton, rocketButton, colonyButton, portalButton, vortexButton, galaxyButton, duplicatorButton, dysonButton, blackHoleButton, afterlifeButton, singularityButton, universeButton, multiverseButton]

@onready var idleUpgrades:Dictionary = {
	"HYENA SNACK" : [0, snackButton.bigPrice.toString()],
	"HYENA TRAP" : [0, trapButton.bigPrice.toString()],
	"HYENA DRONE" : [0, droneButton.bigPrice.toString()],
	"HYENA ENCLOSURE" : [0, enclosureButton.bigPrice.toString()],
	"HYENA ZOO" : [0, zooButton.bigPrice.toString()],
	"HYENA PARK" : [0, parkButton.bigPrice.toString()],
	"HYENA SANCTUARY" : [0, sanctuaryButton.bigPrice.toString()],
	"HYENA SPELL" : [0, spellButton.bigPrice.toString()],
	"HYENA ROCKET" : [0, rocketButton.bigPrice.toString()],
	"HYENA COLONY" : [0, colonyButton.bigPrice.toString()],
	"HYENA PORTAL" : [0, portalButton.bigPrice.toString()],
	"HYENA VORTEX" : [0, vortexButton.bigPrice.toString()],
	"HYENA GALAXY" : [0, galaxyButton.bigPrice.toString()],
	"HYENA DUPLICATOR" : [0, duplicatorButton.bigPrice.toString()],
	"HYENA DYSON SPHERE" : [0, dysonButton.bigPrice.toString()],
	"HYENA BLACK HOLE" : [0, blackHoleButton.bigPrice.toString()],
	"HYENA AFTERLIFE" : [0, afterlifeButton.bigPrice.toString()],
	"HYENA SINGULARITY" : [0, singularityButton.bigPrice.toString()],
	"HYENA UNIVERSE" : [0, universeButton.bigPrice.toString()],
	"HYENA MULTIVERSE" : [0, multiverseButton.bigPrice.toString()],
}
var idleProduction:Dictionary = {
	"HYENA SNACK" : 0.1,
	"HYENA TRAP" : 1,
	"HYENA DRONE" : 11,
	"HYENA ENCLOSURE" : 54,
	"HYENA ZOO" : 94,
	"HYENA PARK" : 3.6e2,
	"HYENA SANCTUARY" : 3.1e3,
	"HYENA SPELL" : 3.04e4,
	"HYENA ROCKET" : 1.3e5,
	"HYENA COLONY" : 1e6,
	"HYENA PORTAL" : 3.65e7,
	"HYENA VORTEX" : 8.2e7,
	"HYENA GALAXY" : 1e9,
	"HYENA DUPLICATOR" : 8e10,
	"HYENA DYSON SPHERE" : 9.9e11,
	"HYENA BLACK HOLE" : 2.2e13,
	"HYENA AFTERLIFE" : 6.4e14,
	"HYENA SINGULARITY" : 1.1e16,
	"HYENA UNIVERSE" : 2e18,
	"HYENA MULTIVERSE" : 3.33e19
}

const FLOAT_MIN = 1.79769e-308
const MAX_MANTISSA = 1209600
 
var curIdle = 1

@onready var musicPlayer = $Music

var counterScene = preload("res://minigames/hyena_clicker/Counter.tscn")

const SAVE_PATH: String = "user://hyena.save"



var rng = RandomNumberGenerator.new()

var can_click:bool = false

var hyena_rotation:int = 8

var hyenas:Big = Big.new(0)
var totalHyenas:Big = Big.new(0)


var HPS:Big = Big.new(0)


const MAX_IDLE:int = 1
var idle_timer:float = 3
var idle_loop:int = 1

const maxCPSTimer = 5
var cpsTimer = maxCPSTimer
var cpsData = 0

const MAX_AUTOCLICK:float = 1/10
var autoclick = MAX_AUTOCLICK

var easter_egg_timer:float = rng.randf_range(150,400)
var first_opened:bool = true

var trackList = [
	{"Path" : "res://minigames/hyena_clicker/music/Lets Get Together Now!.ogg",
	"Title" : "Let's Get Together Now!",
	"Artist" : "SLIME GIRLS",
	"Link" : "https://www.youtube.com/watch?v=GoWgI1V_WDA"},
	{"Path" : "res://minigames/hyena_clicker/music/Bargain Bin Boys.ogg",
	"Title" : "Bargain Bin Boys",
	"Artist" : "SLIME GIRLS",
	"Link" : "https://www.youtube.com/watch?v=e7JHrEbnH78"},
	{"Path" : "res://minigames/hyena_clicker/music/Alphys.ogg",
	"Title" : "Alphys",
	"Artist" : "Toby Fox",
	"Link" : "https://tobyfox.bandcamp.com/track/alphys"},
	{"Path" : "res://minigames/hyena_clicker/music/Everything Will Be Okay.ogg",
	"Title" : "Everything Will Be Okay",
	"Artist" : "Garoad",
	"Link" : "https://garoad.bandcamp.com/track/everything-will-be-okay"},
	{"Path" : "res://minigames/hyena_clicker/music/Breezy Palace.ogg",
	"Title" : "Breezy Palace",
	"Artist" : "Camellia, Toby Fox",
	"Link" : "https://dwellersemptypath.bandcamp.com/track/breezy-palace"},
	{"Path" : "res://minigames/hyena_clicker/music/Cool Cat.ogg",
	"Title" : "Cool Cat",
	"Artist" : "Camellia, Temmie Change, Toby Fox",
	"Link" : "https://dwellersemptypath.bandcamp.com/track/cool-cat"},
	{"Path" : "res://minigames/hyena_clicker/music/The Forest Town.ogg",
	"Title" : "The Forest Town",
	"Artist" : "Calum Bowen",
	"Link" : "https://www.youtube.com/watch?v=aFNgCkFOcXo"},
	{"Path" : "res://minigames/hyena_clicker/music/Checking In.ogg",
	"Title" : "Checking In",
	"Artist" : "Lena Raine",
	"Link" : "https://www.youtube.com/watch?v=fOzvP1I5tLU&list=PLe1jcCJWvkWiWLp9h3ge0e5v7n6kxEfOG&index=6"},
	{"Path" : "res://minigames/hyena_clicker/music/Home Sweet Home.ogg",
	"Title" : "Home Sweet Home",
	"Artist" : "Keiichi Suzuki, Hirokazu Tanaka, Hiroshi Kanazu, Toshiyuki Ueno",
	"Link" : "https://www.youtube.com/watch?v=l8HLmavya0M&list=PL1kU0pk5M3GCwzveqamX71sW3RmCzuXB5&index=17"},
	{"Path" : "res://minigames/hyena_clicker/music/My Dearest Friends.ogg",
	"Title" : "My Dearest Friends",
	"Artist" : "Lena Raine",
	"Link" : "https://www.youtube.com/watch?v=VHN63n9y1vg&list=PLe1jcCJWvkWiWLp9h3ge0e5v7n6kxEfOG&index=21"},
	{"Path" : "res://minigames/hyena_clicker/music/Threed, Free at Last.ogg",
	"Title" : "Threed, Free at Last",
	"Artist" : "Keiichi Suzuki, Hirokazu Tanaka, Hiroshi Kanazu, Toshiyuki Ueno",
	"Link" : "https://www.youtube.com/watch?v=GcERPRac04k&list=PL1kU0pk5M3GCwzveqamX71sW3RmCzuXB5&index=63"},
	{"Path" : "res://minigames/hyena_clicker/music/Knoddys Resort.ogg",
	"Title" : "Knoddys Resort",
	"Artist" : "zKevin",
	"Link" : "https://soundcloud.com/kevinisnotseven/knoddys-resort-1?in=kevinisnotseven/sets/robot64"},
	{"Path" : "res://minigames/hyena_clicker/music/Lost Girl.ogg",
	"Title" : "Lost Girl",
	"Artist" : "Toby Fox",
	"Link" : "https://tobyfox.bandcamp.com/track/lost-girl"},
	{"Path" : "res://minigames/hyena_clicker/music/Lost Library.ogg",
	"Title" : "Lost Library",
	"Artist" : "SLIME GIRLS",
	"Link" : "https://www.youtube.com/watch?v=31jhk_A3mYk"},
	{"Path" : "res://minigames/hyena_clicker/music/It's Raining Somewhere Else.ogg",
	"Title" : "It's Raining Somewhere Else",
	"Artist" : "Toby Fox",
	"Link" : "https://tobyfox.bandcamp.com/track/its-raining-somewhere-else"},
	{"Path" : "res://minigames/hyena_clicker/music/Sweet Sour.ogg",
	"Title" : "Sweet Sour",
	"Artist" : "MasterSwordRemix",
	"Link" : "https://masterswordremix.bandcamp.com/track/sweet-sour"},
]
var curTrack = 0

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	DiscordSDKLoader.run_preset("Hyena")
	
	load_save()
	hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	
	if global.minigames["Hyena Clicker"] == false:
		global.minigames["Hyena Clicker"] = true
		global.save()
	
	if first_opened:
		play_specific_song(0)
		first_opened = false
		save()
	else:
		trackList.shuffle()
		play_specific_song(0)
	shopMenu.visible = false
	
	update_shop_listings()
	update_counter()
	update_yena()
	get_tree().call_group("hyena buttons", "update_price")
	update_discord()

func _process(delta):
	easter_egg_timer -= delta
	if easter_egg_timer <= 0:
		spawn_easter_egg()
		easter_egg_timer = rng.randf_range(250,1000)
	
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
	if idle_timer <= 0:
		idle_timer = MAX_IDLE
		add_hyenas(false)
		idle_loop += 1
		if idle_loop > 10:
			idle_loop = 1
	
	if clickUpgrades["HYENA FOLDER"][0] > 0:
		if Input.is_action_pressed("click") && can_click:
			if autoclick <= 0:
				autoclick = MAX_AUTOCLICK
				click()
		autoclick -= delta
	
	musicButton.position.x += 30 * delta
	if musicButton.position.x > 1280:
		musicButton.position.x = -musicButton.size.x
	if musicButton.modulate.a < 1:
		musicButton.modulate.a += delta

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click") && can_click && clickUpgrades["HYENA FOLDER"][0] == 0:
		click()
	if Input.is_action_just_pressed("back"):
		if global.enteredMiniGameFromMenu:
			Transition.change_scene_to_preset("Main Menu")
		else:
			Transition.change_scene_to_file("res://world/main/main_world.tscn")

func get_CPS(clicks):
	var result:float = clicks / maxCPSTimer
	cpsCounter.text = str(result) + " CLICKS PER SECOND"

func update_HPS():
	if (HPS.isLargerThanOrEqualTo(1000000)):
		hpsCounter.text = HPS.toAmericanName().to_upper() + " HYENAS PER SECOND"
	else:
		hpsCounter.text = HPS.toString() + " HYENAS PER SECOND"

func click():
	add_hyenas(true)
	$Click.play()
	hyena.scale = Vector2(1.1, 1.1)
	cpsData += 1
	
	var instance = counterScene.instantiate()
	if hyena_calculation().isLargerThan(1000):
		instance.move(hyena_calculation().toMetricSymbol())
	else:
		instance.move(hyena_calculation().toString())
	instance.set_position(Vector2(get_global_mouse_position().x - 16, get_global_mouse_position().y - 25))
	add_child(instance)

func add_hyenas(isClick:bool = true):
	if (isClick):
			hyenas.plus(hyena_calculation())
			totalHyenas.plus(hyena_calculation())
	else:
		hyenas.plus(idle_calculation())
		totalHyenas.plus(idle_calculation())
	update_discord()
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
	if clickUpgrades["HYENA FOLDER"][0] >= 1:
		$HyenaPlayer.play('folder')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	else:
		if hyenaInRange("0","999"):
			$HyenaPlayer.play('stage 1')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("1e3", "4999"):
			$HyenaPlayer.play('stage 2')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("5e3","49999"):
			$HyenaPlayer.play('stage 3')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("5e4", "999999"):
			$HyenaPlayer.play('stage 4')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("1e6", "249999999"):
			$HyenaPlayer.play('stage 5')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("2.5e8", "4999999999"):
			$HyenaPlayer.play('stage 6')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("5e9", "99999999999999"):
			$HyenaPlayer.play('stage 7')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("1e14", "499999999999999"):
			$HyenaPlayer.play('stage 8')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("500000000000000", "999999999999999999"):
			$HyenaPlayer.play('stage 9')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenas.isLargerThanOrEqualTo("1000000000000000000"):
			$HyenaPlayer.play('stage 10')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
func hyenaInRange(val1:String, val2:String):
	if hyenas.isLargerThanOrEqualTo(val1) and hyenas.isLessThan(val2):
		return true
	else:
		return false

func hyena_calculation():
	var hyena_num:Big = Big.new(1)
	for key in clickUpgrades.keys():
		hyena_num.plus(Big.new(clickUpgrades[key][0]).multiply(clickProduction[key]))
	
	return hyena_num

func idle_calculation():
	var hyena_num:Big = Big.new(0)
	if idle_loop == 10:
		hyena_num.plus(idleUpgrades["HYENA SNACK"][0])
	hyena_num.plus(Big.new(HPS).roundDown())
	
	return hyena_num

func spawn_easter_egg():
	match rng.randi_range(0, 3):
		0:
			$IdleAnims.play("creature_run")
			$TheCreature.position.x = 1300
			var tween = create_tween()
			tween.tween_property($TheCreature, "position", Vector2(-200, $TheCreature.position.y), 3)
		1:
			$IdleAnims.play("popup")
		2:
			$IdleAnims.play('jumpscare')
			if global.isWindowFocused:
				$JumpscareSound.play()
		3:
			$HyenaPlayer.play('secret')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)

func _on_hyena_mouse_entered():
	can_click = true
func _on_hyena_mouse_exited():
	can_click = false

func save():
	var hyenaString = hyenas.toString()
	var totalString = totalHyenas.toString()
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"FirstTime": first_opened,
		"Hyenas": hyenaString,
		"Total Hyenas": totalString,
		
		"CurIdle": curIdle,
		"CurClick": curClick,
		
		"Click Upgrades": clickUpgrades,
		"Idle Upgrades": idleUpgrades,
	}
	var jstr = JSON.stringify(data)
	
	file.store_line(jstr)
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
				totalHyenas = Big.new(current_line["Total Hyenas"])
				
				curIdle = current_line["CurIdle"]
				curClick = current_line["CurClick"]
				
				clickUpgrades = current_line["Click Upgrades"]
				for i in clickButtons.size():
					update_item_price(clickButtons[i])
					if clickButtons[i].limit != 0 and clickButtons[i].limit <= clickUpgrades[clickButtons[i].item][0]:
						clickButtons[i].disable()
				
				idleUpgrades = current_line["Idle Upgrades"]
				for i in idleButtons.size():
					update_item_price(idleButtons[i])
					HPS.plus(idleUpgrades[idleButtons[i].item][0] * idleProduction[idleButtons[i].item])
	update_HPS()

func _on_shop_button_pressed():
	can_click = false
	if (shopMenu.visible == false):
		shopMenu.visible = true
	elif (shopMenu.visible == true):
		shopMenu.visible = false
func on_item_button_clicked(button):
	if hyenas.isLargerThanOrEqualTo(button.bigPrice):
		remove_hyenas(button.bigPrice)
		buy_item(button)
		
		update_item_price(button)
		button.update_price()
		$KaChing.play()
		if button.item == "HYENA FOLDER":
			update_yena()
		
		update_HPS()

func update_item_price(button):
	if button.limit == 0:
		button.bigPrice = Big.new(idleUpgrades[button.item][1]).multiply(Big.new(1.25).powerInt(idleUpgrades[button.item][0]))
	else:
		button.bigPrice = Big.new(clickUpgrades[button.item][1]).multiply(Big.new(1.5).powerInt(clickUpgrades[button.item][0]))
	button.bigPrice.roundDown()

func buy_item(button):
	for i in clickButtons.size():
		if clickButtons[i].item == button.item:
			clickUpgrades[clickButtons[i].item][0] += 1
			if clickUpgrades[clickButtons[i].item][0] == 1:
				curClick += 1
			if clickUpgrades[clickButtons[i].item][0] >= button.limit and button.limit > 0:
				button.disable()
	for i in idleButtons.size():
		if idleButtons[i].item == button.item:
			idleUpgrades[idleButtons[i].item][0] += 1
			if idleUpgrades[idleButtons[i].item][0] == 1:
				curIdle += 1
			HPS.plus(idleProduction[idleButtons[i].item])
	
	update_shop_listings()

func update_shop_listings():
	for i in range(idleButtons.size()):
		if i < curIdle:
			idleButtons[i].visible = true
		else:
			idleButtons[i].visible = false
	for i in range(clickUpgrades.size()):
		if i < curClick:
			clickButtons[i].visible = true
		else:
			clickButtons[i].visible = false
	
func play_random_song():
	var trackListCopy = trackList
	trackListCopy.shuffle()
	musicPlayer.stream = load(trackListCopy[0]["Path"])
	
	var tween = create_tween()
	musicPlayer.volume_db = -80
	tween.tween_property(musicPlayer, "volume_db", 0, 1)
	
	update_song_text(trackListCopy[0]["Title"], trackListCopy[0]["Artist"], trackListCopy[0]["Link"])
	musicPlayer.play()
func play_specific_song(song:int = 0):
	musicPlayer.stream = load(trackList[song]["Path"])
	var tween = create_tween()
	musicPlayer.volume_db = -80
	tween.tween_property(musicPlayer, "volume_db", 0, 1)
	update_song_text(trackList[song]["Title"], trackList[song]["Artist"], trackList[song]["Link"])
	curTrack += 1
	
	musicPlayer.play()
func _on_music_finished():
	if curTrack >= trackList.size():
		trackList.shuffle()
		curTrack = 0
	play_specific_song(curTrack)

func update_song_text(title:String, artist:String, link:String):
	var textToRepeat:String
	textToRepeat = "       " + '"' + title + '"' + " : " + artist + "       "
	var repeatTimes = floor(1280 / textToRepeat.length())
	musicButton.text = ' '
	for i in range(repeatTimes):
		musicButton.text += textToRepeat
	musicButton.position.x = -musicButton.size.x
	musicButton.modulate.a = 0
	musicButton.uri = link


func _on_texture_button_toggled(toggled_on):
	if toggled_on:
		musicPlayer.stream_paused = true
	else:
		musicPlayer.stream_paused = false

func update_discord():
	if hyenas.isLargerThan(1000000):
		DiscordSDK.state = hyenas.toAmericanName().to_upper() + " H"
	else:
		DiscordSDK.state = hyenas.toString() + " H"
	DiscordSDK.refresh()
