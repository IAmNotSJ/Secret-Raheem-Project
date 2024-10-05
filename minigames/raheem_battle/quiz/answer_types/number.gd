extends SpinBox

@export var answerKey:String

var play_audio = false

func _ready():
	value = Saves.battle_quiz[answerKey]
	play_audio = true

func _on_value_changed(daValue: float) -> void:
	if play_audio:
		$audio.play()
		Saves.battle_quiz[answerKey] = daValue
		Saves.save(Saves.SaveTypes.BATTLE)
