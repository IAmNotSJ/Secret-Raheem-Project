@tool
extends OptionButton

@export var answerKey:String

@export var answers:Array[String] = [] :
	set(value):
		answers = value
		_remake_answers()

func _ready():
	_remake_answers()

func _remake_answers():
	clear()
	for answer in answers:
		add_item(answer)
