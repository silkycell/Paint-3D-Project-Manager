extends Button

func _on_pressed():
	get_node("%ExportHandler").begin_export(get_node("%ProjectPanel").selected_project)
