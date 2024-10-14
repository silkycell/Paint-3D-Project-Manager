extends Node

# TODO: This bad. Fix please. OK!

var use_24_hour:bool = false

func _init():
	load_settings()

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	
	if err != OK:
		return
	
	for setting in config.get_section_keys("Settings"):
		set(setting, config.get_value("Settings", setting))

func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("Settings", "use_24_hour", use_24_hour)
	
	config.save("user://config.cfg")
