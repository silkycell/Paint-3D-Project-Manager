extends Control

const JSON_VERSION:float = 1
const REPLACETEXT:String = "The file \"%s\" already exists.\nDo you want to replace it?"

@onready var export_dialog = $ExportDialog
@onready var replace_file_confirmation = $ReplaceFileConfirmation

var project_to_export:Project
var export_thread:Thread

signal export_thread_update
signal finished_exporting

func _ready():
	export_dialog.canceled.connect(exit_export)
	hide()

func begin_export(project:Project):
	visible = true
	project_to_export = project
	export_dialog.visible = true

func exit_export():
	project_to_export = null
	export_dialog.visible = false
	visible = false

func _on_export_dialog_file_selected(path:String):
	if path.get_extension() == "":
		path += ".p3d"
	
	# this code is stupid, if theres a way to un-stupid it please let me know
	var should_continue = true
	if FileAccess.file_exists(path):
		replace_file_confirmation.dialog_text = REPLACETEXT % path
		replace_file_confirmation.visible = true
		
		replace_file_confirmation.canceled.connect(func():
			exit_export()
			should_continue = false
		)
		
		await replace_file_confirmation.confirmed
	
	if should_continue:
		if export_thread != null: export_thread.wait_to_finish()
		export_thread = Thread.new()
		export_thread.start(export_project.bind(project_to_export, path))
		
		await finished_exporting
		
		exit_export()

func export_project(project:Project, save_path:String):
	call_deferred("emit_signal", "export_thread_update", "start", {})
	var project_path = project.absolute_project_folder
	var files_to_write = {}
	
	var data = {
		"version": JSON_VERSION,
		"project_data": project.to_dict()
	}
	
	files_to_write["data.json"] = JSON.stringify(data, "	", false, true).to_ascii_buffer()
	
	var dir_access := DirAccess.open(project_path)
	if dir_access != null:
		dir_access.list_dir_begin()
		var file_name = dir_access.get_next()
		
		var count = 0
		while file_name != "":
			if !dir_access.current_is_dir():
				count += 1
				call_deferred("emit_signal", "export_thread_update", "index", {
					"count" = count
				})
				files_to_write["project/".path_join(file_name)] = FileAccess.get_file_as_bytes(project_path.path_join(file_name))
			
			file_name = dir_access.get_next()
	else:
		push_error("An error occured while trying to open ", project_path)
		return
	
	dir_access.list_dir_end()
	
	var zip_packer := ZIPPacker.new()
	var err := zip_packer.open(save_path, ZIPPacker.APPEND_CREATE)
	
	if err != OK:
		push_error(err)
		return err
	
	var idx = 0
	for key in files_to_write.keys():
		call_deferred("emit_signal", "export_thread_update", "write", {
			"size": files_to_write.size(),
			"idx": idx,
			"file": key
		})
		
		zip_packer.start_file(key)
		zip_packer.write_file(files_to_write[key])
		idx += 1
	
	call_deferred("emit_signal", "export_thread_update", "finish", {})
	call_deferred("emit_signal", "finished_exporting")

func _exit_tree():
	if export_thread != null: export_thread.wait_to_finish()
