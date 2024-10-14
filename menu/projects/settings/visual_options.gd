extends Control

@onready var options:Dictionary = {
	$"GridContainer/24HourTime": "use_24_hour"
}

func _ready():
	for option in options.keys():
		var option_name = options[option]
		
		if option is CheckButton:
			option.button_pressed = get_option(option_name)
			option.pressed.connect(func(): change_option(option_name, option.button_pressed))

func get_option(option_name:String):
	return SettingsGlobal.get(option_name)

func change_option(option_name:String, value):
	SettingsGlobal.set(option_name, value)
	SettingsGlobal.save_settings()
