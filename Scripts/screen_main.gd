class_name ItemBalloon
extends Control

@export var Ball_Scene: PackedScene = preload("res://Scenes/item_balloon.tscn")
@export var Action_Two_Text: String = ""

@onready var menu_bar: UiBarTop = $BarTop
@onready var ui_win: Panel = $WinPanel
@onready var ui_win_label: Label = $WinPanel/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelWinner
@onready var ui_count_panel: Panel = $CountPanel
@onready var ui_count_panel_label: Label = $CountPanel/Label

@onready var ui_life_progress: ProgressBar = $ProgressBar
@onready var balloon = $SubGame/SubViewport/ItemBalloon

var add_ball_in: int = 0

func _ready():
	GameSettings.apply_custom_key_bindings()
	init_ui()
	balloon.request_life()
	pass
	
func _input(event: InputEvent) -> void:
	var event_name: String = GameSettings.get_action_name(event)
	if event_name.to_lower().contains("ball"):
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
	pass

func _on_item_balloon_balloon_life(life: float) -> void:
	if ui_life_progress is Node:
		ui_life_progress.value = life
	pass
