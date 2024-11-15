extends Node2D

func _ready():
	%character_name.text = Saves.battle_info["Name"]
	%character_name_edit.text = Saves.battle_info["Name"]
	%color_picker_color.modulate = Color(Saves.battle_info["Color"][0], Saves.battle_info["Color"][1], Saves.battle_info["Color"][2])
	%character_name.add_theme_color_override("font_color", Color(Saves.battle_info["Color"][0], Saves.battle_info["Color"][1], Saves.battle_info["Color"][2]))
	%ColorPicker.color = Color(Saves.battle_info["Color"][0], Saves.battle_info["Color"][1], Saves.battle_info["Color"][2])

func on_dropdown_item_selected(index: int) -> void:
	var character = %dropdown.options[index]
	$character_player.play(character)



func _on_line_edit_text_changed(new_text: String) -> void:
	Saves.battle_info["Name"] = new_text
	%character_name.text = new_text


func _on_color_picker_button_pressed() -> void:
	if %ColorPicker.visible == true:
		%ColorPicker.visible = false
	else:
		%ColorPicker.visible = true


func _on_color_picker_color_changed(color: Color) -> void:
	var saved_color = [color.r, color.g, color.b]
	Saves.battle_info["Color"] = saved_color
	%color_picker_color.modulate = Color(saved_color[0], saved_color[1], saved_color[2])
	%character_name.add_theme_color_override("font_color", Color(saved_color[0], saved_color[1], saved_color[2]))
	Saves.save(Saves.SaveTypes.BATTLE)
