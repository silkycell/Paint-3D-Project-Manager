extends Button

@export var settings_menu:Control

func _ready():
	settings_menu.visible = false

func _on_toggled(toggled_on):
	settings_menu.visible = toggled_on
