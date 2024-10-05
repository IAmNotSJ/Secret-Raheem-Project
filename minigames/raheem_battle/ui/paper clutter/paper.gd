extends Node2D

@onready var ui = get_parent().get_parent()

const crumple_scene = preload("res://minigames/raheem_battle/ui/paper clutter/crumple.tscn")

var crumples = []
var skip_turn:bool = false

func _ready():
	# This shit is just ugly in the editor
	visible = true
	ui.turn_ended.connect(_turn_ended)

func _input(_event):
	$Mouse.global_position = get_global_mouse_position()

func generate_crumple():
	#await get_parent().finished
	#print('guh?')
	await ui.turn_started
	for i in range(10):
		var crumple = crumple_scene.instantiate()
		crumple.position = Vector2(randi_range(0, 720), randi_range(-932, -98))
		crumples.append(crumple)
		$crumples.add_child(crumple)
	skip_turn = true

func _turn_ended():
	if !skip_turn:
		if $crumples.get_children().size() >= 2:
			$crumples.get_children()[0].queue_free()
			$crumples.get_children()[1].queue_free()
	else:
		skip_turn = false
