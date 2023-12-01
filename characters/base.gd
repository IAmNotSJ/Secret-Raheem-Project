class_name CharacterBase extends CharacterBody2D

@export var walk_speed:int

@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
@onready var animationTree:AnimationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

var pause_inputs:bool = false

var sj_in_range:bool = false

var input_vector:Vector2 = Vector2.ZERO

func _ready():
	animationTree.active = true

func _unhandled_input(_event: InputEvent) -> void:
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if sj_in_range == true:
		if Input.is_action_just_pressed("ui_accept") and pause_inputs == false:
			DialogueManager.show_dialogue_balloon(load("res://dialogue/sj/dialogue.dialogue"), "start")

func _physics_process(_delta):
	if input_vector != Vector2.ZERO:
		velocity = input_vector * walk_speed
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)
		
		animationState.travel("Walk")
	else:
		velocity = Vector2.ZERO
		animationState.travel("Idle")
		
	move_and_slide()

func _on_interaction_area_entered(area):
	if area.owner.char_name == "sj":
		sj_in_range = true
	
	print("AYAYAYA")


func _on_interaction_area_exited(area):
	if area.owner.char_name == "sj":
		sj_in_range = false
