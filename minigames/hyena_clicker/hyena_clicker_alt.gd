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
	"HYENA NET" : [0, 1, netButton.bigPrice.toString()],
	"HYENA MEAT" : [0, 3, meatButton.bigPrice.toString()],
	"HYENA ENCYCLOPEDIA" : [0, 8, encyclopediaButton.bigPrice.toString()],
	"HYENA CALL" : [0, 20, callButton.bigPrice.toString()],
	"HYENA TOME" : [0, 56, tomeButton.bigPrice.toString()],
	"HYENA TIME MACHINE" : [0, 86, timeMachineButton.bigPrice.toString()],
	"HYENA ARMY" : [0, 123, armyButton.bigPrice.toString()],
	"HYENA DARK ARTS" : [0, 450, darkArtButton.bigPrice.toString()],
	"HYENA PRISM" : [0, 1130, prismButton.bigPrice.toString()],
	"HYENA DARK MATTER" : [0, 4500, darkMatterButton.bigPrice.toString()],
	"HYENA AUGMENTOR" : [0, 11200, augmentorButton.bigPrice.toString()],
	"HYENA MULTILEVEL QUANTUM MANIPULATOR" : [0, 96000, multiLevelQuantumManipulatorButton.bigPrice.toString()],
	"HYENA FORCE" : [0, 350000, yenaforceButton.bigPrice.toString()],
	"HYENA FOLDER" : [0, 1000000, folderButton.bigPrice.toString()],
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
	"HYENA SNACK" : [0, 0.1, snackButton.bigPrice.toString()],
	"HYENA TRAP" : [0, 1, trapButton.bigPrice.toString()],
	"HYENA DRONE" : [0, 11, droneButton.bigPrice.toString()],
	"HYENA ENCLOSURE" : [0, 54, enclosureButton.bigPrice.toString()],
	"HYENA ZOO" : [0, 94, zooButton.bigPrice.toString()],
	"HYENA PARK" : [0, 140, parkButton.bigPrice.toString()],
	"HYENA SANCTUARY" : [0, 890, sanctuaryButton.bigPrice.toString()],
	"HYENA SPELL" : [0, 1400, spellButton.bigPrice.toString()],
	"HYENA ROCKET" : [0, 3500, rocketButton.bigPrice.toString()],
	"HYENA COLONY" : [0, 9999, colonyButton.bigPrice.toString()],
	"HYENA PORTAL" : [0, 26500, portalButton.bigPrice.toString()],
	"HYENA VORTEX" : [0, 89000, vortexButton.bigPrice.toString()],
	"HYENA GALAXY" : [0, 500000, galaxyButton.bigPrice.toString()],
	"HYENA DUPLICATOR" : [0, 1300000, duplicatorButton.bigPrice.toString()],
	"HYENA DYSON SPHERE" : [0, 12500000, dysonButton.bigPrice.toString()],
	"HYENA BLACK HOLE" : [0, 98000000, blackHoleButton.bigPrice.toString()],
	"HYENA AFTERLIFE" : [0, 340000000, afterlifeButton.bigPrice.toString()],
	"HYENA SINGULARITY" : [0, 1100000000, singularityButton.bigPrice.toString()],
	"HYENA UNIVERSE" : [0, 8900000000, universeButton.bigPrice.toString()],
	"HYENA MULTIVERSE" : [0, 33300000000, multiverseButton.bigPrice.toString()],
}

var curIdle = 1

@onready var musicPlayer = $Music

var counterScene = preload("res://minigames/hyena_clicker/Counter.tscn")

const SAVE_PATH: String = "user://hyena.save"

const FLOAT_MIN = 1.79769e-308

var rng = RandomNumberGenerator.new()

var can_click:bool = false

var hyena_rotation:int = 8

var hyenas:Big = Big.new(0)


var HPS:Big = Big.new(0)


const MAX_IDLE:int = 1
var idle_timer:float = 3
var idle_loop:int = 1

const maxCPSTimer = 2
var cpsTimer = maxCPSTimer
var cpsData = 0

var easter_egg_timer:float = rng.randf_range(250,800)
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
	
	update_shop_listings()
	update_counter()
	update_yena()
	get_tree().call_group("hyena buttons", "update_price")

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
	
	musicButton.position.x += 30 * delta
	if musicButton.position.x > 1280:
		musicButton.position.x = -musicButton.size.x
	if musicButton.modulate.a < 1:
		musicButton.modulate.a += delta

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
		$HyenaPlayer.play('stage 4')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenaInRange(1000000, 249999999):
		$HyenaPlayer.play('stage 5')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenaInRange(250000000, 4999999999):
		$HyenaPlayer.play('stage 6')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenaInRange(5000000000, 14999999999):
		$HyenaPlayer.play('stage 7')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	elif hyenaInRange(15000000000, 100000000000):
		$HyenaPlayer.play('stage 8')
		hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
func hyenaInRange(val1:int, val2:int):
	if hyenas.isLargerThanOrEqualTo(val1) and hyenas.isLessThan(val2):
		return true
	else:
		return false

func hyena_calculation():
	var hyena_num:Big = Big.new(1)
	for upgrade in clickUpgrades.values():
		hyena_num.plus(upgrade[0] * upgrade[1])
	return hyena_num

func idle_calculation():
	var hyena_num:Big = Big.new(0)
	if idle_loop == 10:
		hyena_num.plus(idleUpgrades["HYENA SNACK"][0])
	for upgrade in idleUpgrades.values():
		if !upgrade[1] < 1:
			hyena_num.plus(upgrade[0] * upgrade[1])
	
	return hyena_num

func spawn_easter_egg():
	match rng.randi_range(0, 2):
		0:
			$IdleAnims.play("creature_run")
			$TheCreature.position.x = 1300
			var tween = create_tween()
			tween.tween_property($TheCreature, "position", Vector2(-200, $TheCreature.position.y), 3)
		1:
			$IdleAnims.play("popup")
		2:
			$IdleAnims.play('jumpscare')
			#$JumpscareSound.play()

func _on_hyena_mouse_entered():
	can_click = true
func _on_hyena_mouse_exited():
	can_click = false

func save():
	var hyenaString = hyenas.toString()
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"FirstTime": first_opened,
		"Hyenas": hyenaString,
		
		"CurIdle": curIdle,
		"CurClick": curClick,
		
		"Click Upgrades": clickUpgrades,
		"Idle Upgrades": idleUpgrades,
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
				
				curIdle = current_line["CurIdle"]
				curClick = current_line["CurClick"]
				
				clickUpgrades = current_line["Click Upgrades"]
				for i in clickButtons.size():
					clickButtons[i].bigPrice = Big.new(clickUpgrades[clickButtons[i].item][2])
					if clickButtons[i].limit != 0 and clickButtons[i].limit <= clickUpgrades[clickButtons[i].item][0]:
						clickButtons[i].disable()
				
				idleUpgrades = current_line["Idle Upgrades"]
				for i in idleButtons.size():
					idleButtons[i].bigPrice = Big.new(idleUpgrades[idleButtons[i].item][2])
					HPS.plus(idleUpgrades[idleButtons[i].item][0] * idleUpgrades[idleButtons[i].item][1])
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
		button.multiply_price(button.price_multiplier)
		button.update_price()
		if button.limit == 0:
			idleUpgrades[button.item][2] = button.bigPrice.toString()
		else:
			clickUpgrades[button.item][2] = button.bigPrice.toString()
		$KaChing.play()
		
		buy_item(button)
		
		update_HPS()

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
			HPS.plus(idleUpgrades[idleButtons[i].item][1])
	
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
	trackList.shuffle()
	musicPlayer.stream = load(trackList[0]["Path"])
	update_song_text(trackList[0]["Title"], trackList[0]["Artist"], trackList[0]["Link"])
	
	var tween = create_tween()
	musicPlayer.volume_db = -80
	tween.tween_property(musicPlayer, "volume_db", 0, 1)
	
	musicPlayer.play()
func play_specific_song(song:int = 0):
	musicPlayer.stream = load(trackList[song]["Path"])
	var tween = create_tween()
	musicPlayer.volume_db = -80
	tween.tween_property(musicPlayer, "volume_db", 0, 1)
	
	musicPlayer.play()
func _on_music_finished():
	play_random_song()

func update_song_text(title:String, artist:String, link:String):
	musicButton.text = " "
	for i in range(8):
		musicButton.text += '"' + title + '"' + " : " + artist + "       "
	musicButton.position.x = -musicButton.size.x
	musicButton.modulate.a = 0
	musicButton.uri = link


func _on_texture_button_toggled(toggled_on):
	if toggled_on:
		musicPlayer.stream_paused = true
	else:
		musicPlayer.stream_paused = false
