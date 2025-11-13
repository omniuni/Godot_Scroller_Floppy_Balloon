extends Control

## The settings screen controls values in the GameSettings singleton

var ui_setup_complete = false

func _ready():
	ui_setup_complete = false
	GameSettings._Enable_Saving = false
	update_display()
	update_audio_toggle()
	update_audio_sfx_toggle()
	update_player_colors()
	update_seed()
	ui_setup_complete = true
	GameSettings._Enable_Saving = true
	pass
	
func update_display():
	var options_display: OptionButton = $CenterContainer/GridContainer/DisplayOptions
	if GameSettings.Display_Fullscreen:
		for item_index: int in options_display.item_count:
			var item_text: String = options_display.get_item_text(item_index)
			if item_text.to_lower().contains("full"): options_display.select(item_index)
	else:
		for item_index: int in options_display.item_count:
			var item_text: String = options_display.get_item_text(item_index)
			if item_text.to_lower().contains("window"): options_display.select(item_index)
	pass

func update_audio_toggle():
	var buttonEnableAudio: CheckButton = $CenterContainer/GridContainer/AudioCheck
	buttonEnableAudio.button_pressed = GameSettings.Audio_Enabled
	pass
	
func update_audio_sfx_toggle():
	var buttonEnableSFXAudio: CheckButton = $CenterContainer/GridContainer/AudioSFXCheck
	buttonEnableSFXAudio.button_pressed = GameSettings.Audio_SFX_Enabled
	pass
	
func update_player_colors():
	var colorListP1: UiColorList = $CenterContainer/GridContainer/ItemColorListP1
	var colorSquareP1: UiColorSquare = $CenterContainer/GridContainer/HBoxContainer/ColorSquareP1
	colorListP1.Selected_Color = GameSettings.Color_P1
	colorSquareP1.Swatch_Color = GameSettings.Color_P1
	pass
	
func update_seed():
	var line_seed: LineEdit = $CenterContainer/GridContainer/LineEditSeed
	line_seed.text = str(GameSettings.Seed)
	pass

func _on_audio_check_toggled(toggled_on: bool) -> void:
	GameSettings.Audio_Enabled = toggled_on
	update_audio_toggle()
	if ui_setup_complete:
		AudioManager.beep_ui()
	pass

func _on_audio_sfx_check_toggled(toggled_on: bool) -> void:
	GameSettings.Audio_SFX_Enabled = toggled_on
	update_audio_sfx_toggle()
	if ui_setup_complete:
		AudioManager.beep_ui()
	pass # Replace with function body.

func _on_item_color_list_p_1_on_color_selected(color: Color) -> void:
	var colorSquareP1: UiColorSquare = $CenterContainer/GridContainer/HBoxContainer/ColorSquareP1
	colorSquareP1.Swatch_Color = color
	GameSettings.Color_P1 = color
	if ui_setup_complete:
		AudioManager.beep_ui()
	pass

func _on_display_options_item_selected(index: int) -> void:
	var options_display: OptionButton = $CenterContainer/GridContainer/DisplayOptions
	var value_string: String = options_display.get_item_text(index).to_lower()
	GameSettings.Display_Fullscreen = value_string.contains("full")
	if ui_setup_complete:
		AudioManager.beep_ui()
	GameSettings.apply_display()
	pass

func _on_button_kb_configure_pressed() -> void:
	AudioManager.beep_ui()
	Scenes.change_to(get_tree(), Scenes.bindings)
	pass

func _on_line_edit_seed_text_changed(new_text: String) -> void:
	var regex = RegEx.new()
	regex.compile("[^0-9]")  # Matches anything NOT a digit (0-9)
	var cleaned_text: String = regex.sub(new_text, "", true)  # Replace all matches with empty string
	if cleaned_text != '0' and cleaned_text != '':
		cleaned_text = str(int(cleaned_text))
	if new_text != cleaned_text:
		$CenterContainer/GridContainer/LineEditSeed.text = cleaned_text
		return
	GameSettings.Seed = int(new_text)
	pass
