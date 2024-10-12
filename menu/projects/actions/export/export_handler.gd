extends ActionHandler
class_name ExportHandler

const REPLACETEXT:String = "The file \"%s\" already exists."

@onready var export_dialog = $ExportDialog
@onready var replace_file_popup = $ReplaceFilePopup

func _ready():
	export_dialog.canceled.connect(exit_action)
	super()

func begin_action(project:Project = null):
	super(project)
	export_dialog.visible = true

func exit_action():
	super()
	export_dialog.visible = false

func _on_export_dialog_file_selected(path:String):
	if path.get_extension() == "":
		path += ".p3dpj"
	
	# this code is stupid, if theres a way to un-stupid it please let me know
	var should_continue = true
	if FileAccess.file_exists(path):
		replace_file_popup.title = REPLACETEXT % path.get_file()
		replace_file_popup.visible = true
		
		var choice = await replace_file_popup.choice_selected
		
		if choice == "cancel":
			exit_action()
			should_continue = false
	
	if should_continue:
		if action_thread != null: action_thread.wait_to_finish()
		action_thread = Thread.new()
		action_thread.start(export_project.bind(selected_project, path))
		
		await finished_action
		
		exit_action()

func export_project(project:Project, save_path:String):
	call_deferred("emit_signal", "action_thread_update", "start", {"project": project.name})
	var project_path = project.absolute_project_folder
	var files_to_write = {}
	
	var data = {
		"version": ProjectsJsonAPI.CURRENT_JSON_VERSION,
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
				call_deferred("emit_signal", "action_thread_update", "index", {
					"count" = count,
					"project" = project.name
				})
				files_to_write["project/".path_join(file_name)] = FileAccess.get_file_as_bytes(project_path.path_join(file_name))
			
			file_name = dir_access.get_next()
	else:
		project_path = project_path.replacen(ProjectsJsonAPI.LOCAL_APPDATA_PATH, "%LOCALAPPDATA%")
		display_error_deferred("Error Code: " + str(DirAccess.get_open_error()), "Error accessing path:\n" + project_path)
		return
	
	dir_access.list_dir_end()
	
	var zip_packer := ZIPPacker.new()
	var error := zip_packer.open(save_path, ZIPPacker.APPEND_CREATE)
	
	if error != OK:
		display_error_deferred("Error Code: " + str(error), "Error creating Zip at path:\n" + save_path)
		return
	
	var idx = 0
	for key in files_to_write.keys():
		call_deferred("emit_signal", "action_thread_update", "write", {
			"size": files_to_write.size(),
			"idx": idx,
			"file": key,
			"project": project.name
		})
		
		zip_packer.start_file(key)
		zip_packer.write_file(files_to_write[key])
		idx += 1
	
	call_deferred("emit_signal", "action_thread_update", "finish", {})
	call_deferred("emit_signal", "finished_action")
