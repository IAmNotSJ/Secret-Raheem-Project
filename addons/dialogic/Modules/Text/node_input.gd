class_name DialogicNode_Input
extends Control

## A node that handles mouse input. This allows limiting mouse input to a
## specific region and avoiding conflicts with other UI elements.
## If no Input node is used, the input subsystem will handle mouse input instead.

func _ready():
	add_to_group('dialogic_input')
	gui_input.connect(_on_gui_input)


func _input(event: InputEvent) -> void:
	if Dialogic.Styles.has_active_layout_node() and Dialogic.Styles.get_layout_node().is_inside_tree():
		if Dialogic.Styles.get_layout_node().allow_input == true:
			mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_gui_input(event:InputEvent) -> void:
	DialogicUtil.autoload().Inputs.handle_node_gui_input(event)
