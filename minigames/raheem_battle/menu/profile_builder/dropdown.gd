extends OptionButton

var options = ["wibr", "sj", "cleft", "block", "cherry", "dapper", "slime", "atlas", "dile", "composty", "cost", "lambda", "luna"]

var play_audio = false

func _ready():
	_remake_answers()
	selected = options.find(Saves.battle_info["Character"])
	get_parent().get_parent().on_dropdown_item_selected(options.find(Saves.battle_info["Character"]))
	play_audio = true

func _remake_answers():
	clear()
	for option in options:
		add_item(option.to_upper())


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		global.mouse.make_hidden()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	else:
		global.mouse.make_visible()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)


func _on_pressed() -> void:
	global.mouse.make_hidden()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)


func _on_item_selected(index: int) -> void:
	if play_audio:
		$audio.play()
		var item = options[index].to_lower()
		Saves.battle_info["Character"] = item
		Saves.save(Saves.SaveTypes.BATTLE)
