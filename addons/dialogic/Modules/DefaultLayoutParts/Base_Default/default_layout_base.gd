@tool
extends DialogicLayoutBase

enum TimelineEndedEffects{
	FREE,
	HIDE,
	IDLE
}
## The default layout base scene.

@export var canvas_layer: int = 1

@export_subgroup("Global")
@export var global_bg_color: Color = Color(0, 0, 0, 0.9)
@export var global_font_color: Color = Color("white")
@export_file('*.ttf', '*.tres') var global_font: String = ""
@export var global_font_size: int = 18

@export var timeline_ending_effect:TimelineEndedEffects = TimelineEndedEffects.FREE

@export var use_autoadvance_on_start:bool = false

@export var allow_input:bool = true

func _apply_export_overrides() -> void:
	# apply layer
	set(&'layer', canvas_layer)


