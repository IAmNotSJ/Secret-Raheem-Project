extends Control

signal answered(correct:bool)

var problems = [
	["What is the magnitude of the vector <-4, 7>? Give your answer in 3 significant figures.", "8.06", ""],
	["Which letter represent the vertex within the given picture?", "B", "res://minigames/raheem_battle/ui/geometry/problems/2.png"],
	["What is the area of the triangle within the given picture?", "4", "res://minigames/raheem_battle/ui/geometry/problems/3.png"],
	["Right triangle ABC is shown in the given picture. What is the measure of Angle A if Side c = 5.3m and Side a = 2m? Give your answer in 3 significant figures.", "22.2", "res://minigames/raheem_battle/ui/geometry/problems/4.png"]
]
var problem:int

@onready var ui = get_parent()

func start():
	problem = randi_range(0, problems.size() - 1)
	
	$title.text = problems[problem][0]
	if problems[problem][2] != "":
		$image.texture = load(problems[problem][2])
	
	visible = true
	ui.is_in_preview = true
	ui.card_hand.block_input()
	
	

func _on_submit():
	clear()
	if $answer.text == problems[problem][1]:
		answered.emit(true)
	else:
		answered.emit(false)

func clear():
	ui.card_hand.allow_input()
	ui.is_in_preview = false
	
	
	visible = false