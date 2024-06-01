class_name CharacterBase extends CharacterBody2D

@export var walk_speed:int

@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
@onready var animationTree:AnimationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")



const max_exit = 3
var exit_timer:float = max_exit

var pause_inputs:bool = false

var in_bench:bool = false

var characters_in_range = []
var interaction_in_range = []

var input_vector:Vector2 = Vector2.ZERO

var can_move = true

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	animationTree.active = true

func _unhandled_input(_event: InputEvent) -> void:
	if can_move and Dialogic.current_timeline == null:
		if !in_bench:
			input_vector = Vector2.ZERO
			input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
			input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
			input_vector = input_vector.normalized()
			
			if Input.is_action_just_pressed("ui_accept") and characters_in_range:
				if characters_in_range[0] != null:
					characters_in_range[0].interact(self)
					stop_movement()
		else:
			if Input.is_action_just_pressed("ui_accept"):
				animationPlayer.play('idle_down')
				$Sprite2D.position = Vector2.ZERO
				in_bench = false
	if Input.is_action_just_pressed("hyena"):
		Transition.change_scene_to_preset("Fishing")

func _physics_process(_delta):
	if input_vector != Vector2.ZERO:
		velocity = input_vector * walk_speed
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)
		
		animationState.travel("Walk")
	else:
		velocity = Vector2.ZERO
		animationState.travel("Idle")
		
	if Input.is_action_pressed('back'):
		exit_timer -= _delta
		if exit_timer <= 0:
			Transition.change_scene_to_preset("Main Menu")
	else:
		exit_timer = max_exit
	
	move_and_slide()

func stop_movement():
	velocity = Vector2.ZERO
	input_vector = Vector2.ZERO

func _on_interaction_area_entered(area):
	print("AAAAAAAA")
	characters_in_range.append(area.owner)


func _on_interaction_area_exited(area):
	characters_in_range.erase(area.owner)
