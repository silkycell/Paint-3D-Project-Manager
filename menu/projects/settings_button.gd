extends Button

@export var settings_menu:Control

func _on_toggled(toggled_on):
	settings_menu.visible = toggled_on
	print(toggled_on)
