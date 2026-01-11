extends Node2D

@export var action_name: String = ""
@onready var label: Label = $Label

func _ready() -> void:
	
	InputMap.load_from_project_settings()
	
	for action in InputMap.get_actions():
		if action.containsn(action_name):
			var input_events: Array[InputEvent] = InputMap.action_get_events(action)
			var input_list = ""
			for input_event: InputEvent in input_events:
				input_list+=input_event.as_text().replace("(Physical)", "")+", "
				pass
			label.text = input_list.trim_suffix(", ").strip_edges()
		pass
	
	if GameSettings.Custom_Key_Bindings.has(action_name):
		var restored_event = InputEventKey.new()
		restored_event.keycode = GameSettings.Custom_Key_Bindings[action_name]
		label.text = restored_event.as_text().replace("(Physical)", "")
		
	if label.text.containsn("Space"):
		$Label.visible = false
		$LabelSpace.visible = true
		
	pass
