class_name ItemBalloon
extends Control

@export var Ball_Scene: PackedScene = preload("res://Scenes/item_balloon.tscn")
@export var Action_Two_Text: String = ""

@onready var menu_bar: UiBarTop = $BarTop
@onready var ui_win: Panel = $WinPanel
@onready var ui_win_label: Label = $WinPanel/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelWinner
@onready var ui_count_panel: Panel = $CountPanel
@onready var ui_count_panel_label: Label = $CountPanel/Label
@onready var ui_touch_controls: MarginContainer = $UiTouchControls
@onready var ui_level_time: Label = $TimeLabel

@onready var ui_life_progress: ProgressBar = $ProgressBar
@onready var balloon = $SubGame/SubViewport/ItemBalloon
@onready var ui_level_progress: ProgressBar = $ProgressBarLevel

var level_start: bool = false
var level_time: float = 0

func _ready():
	GameSettings.apply_custom_key_bindings()
	init_ui()
	balloon.request_life()
	if not GameSettings.UI_Touch_Enabled:
		ui_touch_controls.hide()
	pass
	
func _input(event: InputEvent) -> void:
	var event_name: String = GameSettings.get_action_name(event)
	if event_name.to_lower().contains("start"):
		_on_bar_top_on_secondary_action() 
	pass
	
func init_ui() -> void:
	Beeper.bgm_start()
	pass
	
func _notification(notification_int: int) -> void:
	if notification_int == NOTIFICATION_EXIT_TREE:
		Beeper.bgm_stop()
	pass

func _on_bar_top_on_secondary_action() -> void:
	menu_bar.Action_Two = ""
	level_start = true
	level_time = -3.0
	$UiKeycap.visible = false
	pass

func _on_item_balloon_balloon_life(life: float) -> void:
	if ui_life_progress is Node:
		ui_life_progress.value = life
	pass


func _on_button_bump_pressed() -> void:
	var event = InputEventAction.new()
	event.action = "Bump"
	event.pressed = true
	Input.parse_input_event(event)
	pass

func _on_ui_update_timer_timeout() -> void:
	if level_start == true and level_time >= 0:
		balloon.freeze(false)
	if level_start == true and level_time <= 0:
		ui_count_panel.visible = true
		ui_count_panel_label.text = str(ceili(abs(level_time)))
	if level_start == true and level_time >= 0 and ui_count_panel.visible:
		ui_count_panel.visible = false
		AudioManager.beep_ui()
		ui_level_time.visible = true
	if level_time >= 0:
		var minutes := int(level_time / 60)
		var seconds := fmod(level_time, 60.0)
		ui_level_time.text = "%02d:%05.2f" % [minutes, seconds]
	level_time += 0.1
	pass


func _on_sub_game_on_column_rendered(column: int) -> void:
	if ui_level_progress is ProgressBar:
		var mapped_value = remap(column, 10, 1800, 0, 100)
		ui_level_progress.value = clamp(mapped_value, 0, 100)
	pass
