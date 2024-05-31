extends Control

@onready var export_dialog = $ExportDialog
var project_to_export:Project

func begin_export(project:Project):
	project_to_export = project
	export_dialog.visible = true
	visible = true

func _on_export_dialog_file_selected(path:String):
	if path.get_extension() == "":
		path += ".p3d"

func _on_export_dialog_canceled():
	project_to_export = null
	export_dialog.visible = false
	visible = false
