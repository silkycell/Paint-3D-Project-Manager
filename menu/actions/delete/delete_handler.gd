extends ActionHandler

const WARNINGTEXT:String = "Delete \"%s\"?"

@onready var delete_warning_popup = $DeleteWarningPopup

func begin_action(project:Project = null):
	super(project)
	
	delete_warning_popup.title = WARNINGTEXT % project.name
	delete_warning_popup.visible = true
	
	var selection = await delete_warning_popup.choice_selected
	
	if selection == "delete":
		ProjectsJsonAPI.projects.erase(project)
		action_thread = Thread.new()
		action_thread.start(_delete_project.bind(project.name, project.absolute_project_folder))
		
		await finished_action
		
		ProjectsJsonAPI.sort_projects()
		ProjectsJsonAPI.save_json()
		
		get_node("%ProjectsListContainer").generate_buttons()
	
	exit_action()

func _delete_project(project_name:String, folder_path:String):
	var dir = DirAccess.open(folder_path)
	
	if dir == null:
		display_error_deferred("Error Code " + str(DirAccess.get_open_error()), "Error accessing " + folder_path)
		return DirAccess.get_open_error()
	
	var files = dir.get_files()
	for i in range(files.size()):
		call_deferred("emit_signal", "action_thread_update", "delete", {
			"size": files.size(),
			"idx": i,
			"file": files[i],
			"project": project_name
		})
		
		var error = dir.remove(files[i])
		if error != 0:
			display_error_deferred("Error Code " + str(error), "Error while deleting " + files[i] + ".")
			return
	
	DirAccess.remove_absolute(folder_path)
	
	call_deferred("emit_signal", "action_thread_update", "finish", {})
	call_deferred("emit_signal", "finished_action")
