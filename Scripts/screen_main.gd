extends Control

@export var Ball_Scene: PackedScene = preload("res://Scenes/item_ball.tscn")
@export var Action_Two_Text: String = ""

@onready var menu_bar: UiBarTop = $BarTop
@onready var ui_win: Panel = $WinPanel
@onready var ui_win_label: Label = $WinPanel/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LabelWinner
@onready var ui_count_panel: Panel = $CountPanel
@onready var ui_count_panel_label: Label = $CountPanel/Label

var current_ball: ItemBall = null

var add_ball_in: int = 0

func _ready():
	GameSettings.apply_custom_key_bindings()
	init_ui()
	pass
	
func _input(event: InputEvent) -> void:
	var event_name: String = GameSettings.get_action_name(event)
	if event_name.to_lower().contains("ball"):
		_on_bar_top_on_secondary_action()
	pass
	
func init_ui() -> void:
	pass

func _on_bar_top_on_secondary_action() -> void:
	if current_ball == null and add_ball_in == 0:
		add_ball_in = 4
	menu_bar.Action_Two = ""
	pass
