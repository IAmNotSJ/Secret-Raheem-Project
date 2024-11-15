extends SpinBox

@export var answerKey:String

var play_audio = false

func _ready():
	value = Saves.battle_rules["Cards To Win"]
	play_audio = true

func _on_value_changed(daValue: float) -> void:
	if play_audio:
		$audio.play()
	Saves.battle_rules["Cards To Win"] = daValue
	Saves.save(Saves.SaveTypes.BATTLE)
