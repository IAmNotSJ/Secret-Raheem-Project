extends Node2D

@onready var hyena = $Hyena
@onready var counter = $Counter
@onready var shopButton = $ShopButton
@onready var shopMenu = $ShopMenu

@onready var musicPlayer = $AudioStreamPlayer

const SAVE_PATH: String = "user://hyena.bin"

var rng = RandomNumberGenerator.new()

var can_click:bool = false

var hyena_rotation:int = 8

var hyenas:int = 0
var nets:int = 0

var easter_egg_timer:float = rng.randf_range(80,100)

var trackList = [
	"res://minigames/hyena_clicker/music/Lets Get Together Now!.ogg",
	"res://minigames/hyena_clicker/music/Bargain Bin Boys.ogg"
]

func _ready():
	load_save()
	
	shopMenu.visible = false
	
	hyena.pivot_offset = Vector2(hyena.size.x / 2, hyena.size.y / 2)
	update_counter()

func _process(delta):
	easter_egg_timer -= delta
	
	if easter_egg_timer <= 0:
		easter_egg_timer = rng.randf_range(80,100)
		
		spawn_easter_egg()
	if hyena.rotation_degrees <= -15:
		hyena_rotation = +8
	elif hyena.rotation_degrees >= 15:
		hyena_rotation = -8
	hyena.rotation_degrees += hyena_rotation * delta
	hyena.scale = hyena.scale.lerp(Vector2(1, 1), delta * 5)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click") && can_click:
		click()

func click():
	add_hyenas()
	hyena.scale = Vector2(1.1, 1.1)

func hyena_calculation():
	var hyena_num:int = 1
	if (nets != 0):
		hyena_num += nets
	return hyena_num

func add_hyenas():
	hyenas += hyena_calculation()
	save()
	update_counter()

func remove_hyenas(amount):
	hyenas -= amount
	save()
	update_counter()

func update_counter():
	counter.text = "HYENAS: " + str(hyenas)

func spawn_easter_egg():
	$IdleAnims.play("creature_run")
	$TheCreature.position.x = 1300
	var tween = create_tween()
	tween.tween_property($TheCreature, "position", Vector2(-200, $TheCreature.position.y), 3)

func _on_hyena_mouse_entered():
	can_click = true

func _on_hyena_mouse_exited():
	can_click = false

func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"Hyenas": hyenas,
		"Nets": nets
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
				hyenas = current_line["Hyenas"]
				nets = current_line["Nets"]
				$"ShopMenu/Net Button".price_multiplier = $"ShopMenu/Net Button".price_multiplier * nets
				$"ShopMenu/Net Button".price *= $"ShopMenu/Net Button".price_multiplier



func _on_shop_button_pressed():
	print('whar')
	can_click = false
	if (shopMenu.visible == false):
		print('guh')
		shopMenu.visible = true
	elif (shopMenu.visible == true):
		shopMenu.visible = false


func _on_net_button_pressed():
	if hyenas >= $"ShopMenu/Net Button".price:
		remove_hyenas($"ShopMenu/Net Button".price)
		print('BOUGHT NET FOR: ' + str($"ShopMenu/Net Button".price) + ' HYENAS')
		print('NETS: ' + str(nets))
		$"ShopMenu/Net Button".price *= $"ShopMenu/Net Button".price_multiplier
		nets += 1
		


func _on_audio_stream_player_finished():
	trackList.shuffle()
	musicPlayer.stream = load(trackList[0])
	var tween = create_tween()
	musicPlayer.volume_db = -80
	tween.tween_property(musicPlayer, "volume_db", 0, 1)
	
	musicPlayer.play()
