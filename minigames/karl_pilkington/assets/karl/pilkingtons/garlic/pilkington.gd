extends PilkingtonBase

const fartScene = preload("res://minigames/karl_pilkington/assets/karl/pilkingtons/garlic/cloud.tscn")

const max_fart_timer = 10
var fart_timer = 0

func _physics_process(delta):
	fart_timer -= delta
	super(delta)

func _unhandled_input(event):
	super(event)
	if Input.is_action_just_pressed("karl_special"):
		spawn_fart()

func spawn_fart():
	print('FART')
	if fart_timer <= 0:
		fart_timer = max_fart_timer
		var fart = fartScene.instantiate()
		fart.global_position = global_position
		get_tree().root.get_node("Pilkington").get_node("KarlPilkington").add_child(fart)
