extends OptionButton

@export var answerKey:String = ""

var play_audio = false

@export var answers:Array[String] = [] :
	set(value):
		answers = value
		_remake_answers()

func _ready():
	_remake_answers()
	if Saves.battle_quiz.keys().has(answerKey):
		selected = answers.find(Saves.battle_quiz[answerKey])
	else:
		print("BATTLE QUIZ DOES NOT HAVE KEY " + answerKey)
	play_audio = true

func _remake_answers():
	clear()
	for answer in answers:
		add_item(answer)


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
		Saves.battle_quiz[answerKey] = answers[index]
		Saves.save(Saves.SaveTypes.BATTLE)
