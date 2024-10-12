extends Button
class_name ActionButton

@export var target_action:ActionHandler

func _on_pressed():
	target_action.begin_action(GlobalSignalHandler.selected_project)
