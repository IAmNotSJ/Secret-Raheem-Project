extends CheckBox

@export var answerKey:String

var play_audio = false

func _ready():
	button_pressed = Saves.battle_quiz[answerKey]
	play_audio = true

func _on_toggled(toggled_on: bool) -> void:
	if play_audio:
		$audio.play()
		Saves.battle_quiz[answerKey] = toggled_on
		Saves.save(Saves.SaveTypes.BATTLE)
