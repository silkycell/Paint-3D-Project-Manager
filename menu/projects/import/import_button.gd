extends Button

func _on_pressed():
	get_node("%ImportHandler").begin_import()
