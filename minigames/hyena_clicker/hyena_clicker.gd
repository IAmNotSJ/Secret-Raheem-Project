extends Node2D

@onready var mouseWindow = $MouseWindow
@onready var musicPlayer = $Music
@onready var hyena_player = $HyenaPlayer

@onready var hyena = $Hyena
@onready var counter = $UI/hyena_counter
@onready var cpsCounter = $UI/cps_counter
@onready var hpsCounter = $UI/hps_counter
@onready var shopButton = $UI/shop_button
@onready var shopMenu = $shop_menu
@onready var stats_menu = $stats_menu

@onready var musicButton = %MusicButton

@onready var netButton = $"shop_menu/ClickContainer/VBoxContainer/Net Button"
@onready var meatButton = $"shop_menu/ClickContainer/VBoxContainer/Meat Button"
@onready var encyclopediaButton = $"shop_menu/ClickContainer/VBoxContainer/Encyclopedia Button"
@onready var callButton = $"shop_menu/ClickContainer/VBoxContainer/Call Button"
@onready var tomeButton = $"shop_menu/ClickContainer/VBoxContainer/Tome Button"
@onready var timeMachineButton = $"shop_menu/ClickContainer/VBoxContainer/Time Machine Button"
@onready var armyButton = $"shop_menu/ClickContainer/VBoxContainer/Army Button"
@onready var darkArtButton = $"shop_menu/ClickContainer/VBoxContainer/Dark Art Button"
@onready var prismButton = $"shop_menu/ClickContainer/VBoxContainer/Prism Button"
@onready var darkMatterButton = $"shop_menu/ClickContainer/VBoxContainer/Dark Matter Button"
@onready var augmentorButton = $"shop_menu/ClickContainer/VBoxContainer/Augmentor Button"
@onready var multiLevelQuantumManipulatorButton = $"shop_menu/ClickContainer/VBoxContainer/MultiLevel Quantum Manipulator Button"
@onready var yenaforceButton = $"shop_menu/ClickContainer/VBoxContainer/Yenaforce Button"
@onready var folderButton = $"shop_menu/ClickContainer/VBoxContainer/Folder Button"
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

@onready var snackButton = $"shop_menu/IdleContainer/VBoxContainer/Snack Button"
@onready var trapButton = $"shop_menu/IdleContainer/VBoxContainer/Trap Button"
@onready var droneButton = $"shop_menu/IdleContainer/VBoxContainer/Drone Button"
@onready var enclosureButton = $"shop_menu/IdleContainer/VBoxContainer/Enclosure Button"
@onready var zooButton = $"shop_menu/IdleContainer/VBoxContainer/Zoo Button"
@onready var sanctuaryButton = $"shop_menu/IdleContainer/VBoxContainer/Sanctuary Button"
@onready var spellButton = $"shop_menu/IdleContainer/VBoxContainer/Spell Button"
@onready var parkButton = $"shop_menu/IdleContainer/VBoxContainer/Park Button"
@onready var rocketButton = $"shop_menu/IdleContainer/VBoxContainer/Rocket Button"
@onready var colonyButton = $"shop_menu/IdleContainer/VBoxContainer/Colony Button"
@onready var portalButton = $"shop_menu/IdleContainer/VBoxContainer/Portal Button"
@onready var vortexButton = $"shop_menu/IdleContainer/VBoxContainer/Vortex Button"
@onready var galaxyButton = $"shop_menu/IdleContainer/VBoxContainer/Galaxy Button"
@onready var duplicatorButton = $"shop_menu/IdleContainer/VBoxContainer/Duplicator Button"
@onready var dysonButton = $"shop_menu/IdleContainer/VBoxContainer/Dyson Button"
@onready var blackHoleButton = $"shop_menu/IdleContainer/VBoxContainer/Black Hole Button"
@onready var afterlifeButton = $"shop_menu/IdleContainer/VBoxContainer/Afterlife Button"
@onready var singularityButton = $"shop_menu/IdleContainer/VBoxContainer/Singularity Button"
@onready var universeButton = $"shop_menu/IdleContainer/VBoxContainer/Universe Button"
@onready var multiverseButton = $"shop_menu/IdleContainer/VBoxContainer/Multiverse Button"
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

@onready var card_button = $shop_menu/HyenaFolder

const FLOAT_MIN = 1.79769e-308
const MAX_MANTISSA = 1209600
 
var curIdle = 1

var counterScene = preload("res://minigames/hyena_clicker/misc/counter/counter.tscn")



var rng = RandomNumberGenerator.new()

var can_click:bool = false

var hyena_rotation:int = 8

var hyenas:Big = Big.new(0)
var totalHyenas:Big = Big.new(0)
var clicks:int = 0
var highest_cps:float = 0


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

func _ready():
	global.toggle_mouse_visibility()
	DiscordSDKLoader.run_preset("Hyena")
	
	load_save()
	hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	
	card_button.left_clicked.connect(_on_card_clicked)
	
	if Saves.minigames["Hyena Clicker"] == false:
		Saves.minigames["Hyena Clicker"] = true
		Saves.save(Saves.SaveTypes.HYENA)
	
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

func get_CPS(daClicks):
	var result:float = daClicks / maxCPSTimer
	if result > highest_cps:
		highest_cps = result
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
	clicks += 1
	
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
		hyena_player.play('folder')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	else:
		if hyenaInRange("0","999"):
			hyena_player.play('stage 1')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("1e3", "4999"):
			hyena_player.play('stage 2')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("5e3","49999"):
			hyena_player.play('stage 3')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("5e4", "999999"):
			hyena_player.play('stage 4')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("1e6", "249999999"):
			hyena_player.play('stage 5')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("2.5e8", "4999999999"):
			hyena_player.play('stage 6')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("5e9", "99999999999999"):
			hyena_player.play('stage 7')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("1e14", "499999999999999"):
			hyena_player.play('stage 8')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenaInRange("500000000000000", "999999999999999999"):
			hyena_player.play('stage 9')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
		elif hyenas.isLargerThanOrEqualTo("1000000000000000000"):
			hyena_player.play('stage 10')
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

func spawn_easter_egg(key:int = -1):
	var easter_egg = rng.randi_range(0, 3)
	if key != -1:
		easter_egg = key
	match easter_egg:
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
			hyena_player.play('secret')
			hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)

func _on_hyena_mouse_entered():
	can_click = true
func _on_hyena_mouse_exited():
	can_click = false

func save():
	var hyenaString = hyenas.toString()
	var totalString = totalHyenas.toString()
	
	Saves.hyena_stats["Hyenas"] = hyenaString
	Saves.hyena_stats["Total Hyenas"] = totalString
	Saves.hyena_stats["CurIdle"] = curIdle
	Saves.hyena_stats["CurClick"] = curClick
	Saves.hyena_stats["Click Upgrades"] = clickUpgrades
	Saves.hyena_stats["Idle Upgrades"] = idleUpgrades
	Saves.hyena_stats["Clicks"] = clicks
	Saves.hyena_stats["Highest CPS"] = highest_cps
	
	Saves.save(Saves.SaveTypes.HYENA)
func load_save():
	hyenas = Big.new(Saves.hyena_stats["Hyenas"])
	totalHyenas = Big.new(Saves.hyena_stats["Total Hyenas"])
	
	curIdle = Saves.hyena_stats["CurIdle"]
	curClick = Saves.hyena_stats["CurClick"]
	
	if Saves.hyena_stats["Click Upgrades"] != {}:
		clickUpgrades = Saves.hyena_stats["Click Upgrades"]
		for i in clickButtons.size():
			update_item_price(clickButtons[i])
			if clickButtons[i].limit != 0 and clickButtons[i].limit <= clickUpgrades[clickButtons[i].item][0]:
				clickButtons[i].disable()
	
	if Saves.hyena_stats["Idle Upgrades"] != {}:
		idleUpgrades = Saves.hyena_stats["Idle Upgrades"]
		for i in idleButtons.size():
			update_item_price(idleButtons[i])
			HPS.plus(idleUpgrades[idleButtons[i].item][0] * idleProduction[idleButtons[i].item])
	update_HPS()
	
	#print(Saves.hyena_stats)
	clicks = Saves.hyena_stats["Clicks"]
	highest_cps = Saves.hyena_stats["Highest CPS"]
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

func _on_shop_button_pressed():
	can_click = false
	if (shopMenu.visible == false):
		shopMenu.visible = true
	elif (shopMenu.visible == true):
		shopMenu.visible = false
	if stats_menu.visible == true:
		stats_menu.visible = false
	if $hyena_folder_card_menu.visible == true:
		$hyena_folder_card_menu.visible = false

func _on_stats_button_pressed():
	can_click = false
	if (stats_menu.visible == false):
		stats_menu.visible = true
		stats_menu.generate_items()
	elif (stats_menu.visible == true):
		stats_menu.visible = false
		stats_menu.clear()
	if shopMenu.visible == true:
		shopMenu.visible = false
	if $hyena_folder_card_menu.visible == true:
		$hyena_folder_card_menu.visible = false

func _on_music_mute_toggled(toggled_on):
	if toggled_on:
		musicPlayer.stream_paused = true
	else:
		musicPlayer.stream_paused = false

func _on_card_clicked(_card):
	if shopMenu.visible == true:
		$hyena_folder_card_menu.visible = true
		$hyena_folder_card_menu.generate_card()
		shopMenu.visible = false
		stats_menu.visible = false

func update_discord():
	if hyenas.isLargerThan(1000000):
		DiscordSDK.state = hyenas.toAmericanName().to_upper() + " H"
	else:
		DiscordSDK.state = hyenas.toString() + " H"
	DiscordSDK.refresh()
