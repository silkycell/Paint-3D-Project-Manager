extends ActionHandler
class_name ImportHandler

const REPLACETEXT:String = "A project with the folder \"%s\" already exists."

@onready var import_dialog := $ImportDialog
@onready var replace_project_popup = $ReplaceProjectPopup

func _ready():
	import_dialog.canceled.connect(exit_action)
	super()

func begin_action(_project:Project = null):
	super(null)
	import_dialog.visible = true

func exit_action():
	super()
	import_dialog.visible = false

func _on_import_dialog_file_selected(path:String):
	var reader := ZIPReader.new()
	var error := reader.open(path)
	
	if error != OK:
		display_error("Error Code: " + str(error), "Error reading ZIP " + path)
		return
	
	var data_json
	
	if !reader.file_exists("data.json"): # old format check
		if !reader.file_exists("exportProjects.json"):
			display_error("Read Error", "This is not a P3D or P3DPJ file!")
			return
		
		# TODO: add support for multi project P3Ds
		var export_projects = JSON.parse_string(reader.read_file("exportProjects.json").get_string_from_ascii())
		
		if export_projects.size() > 1:
			display_error("Import Error", "Support for multi-project P3Ds is not yet implemented.")
			return
		
		data_json = {
			"version": 0,
			"project_data": export_projects[0]
		}
	else:
		data_json = JSON.parse_string(reader.read_file("data.json").get_string_from_ascii())
	
	var project_folder_name = data_json["project_data"]["Path"]
	project_folder_name = project_folder_name.erase(project_folder_name.find("Projects\\"), "Projects\\".length())
	
	if data_json.version > ProjectsJsonAPI.CURRENT_JSON_VERSION:
		display_error("Current version is lesser than JSON version."
		, "\n Please use a more recent version of P3DPM to import this project." 
		+ "\n(Current Version: " + str(ProjectsJsonAPI.CURRENT_JSON_VERSION) + " Project Version: " + str(data_json.version) + ")")
		return
	
	# this code is stupid, if theres a way to un-stupid it please let me know
	var should_continue = true
	if ProjectsJsonAPI.check_proj_folder_exists(project_folder_name) != null:
		replace_project_popup.text = REPLACETEXT % project_folder_name
		replace_project_popup.visible = true
		
		var choice = await replace_project_popup.choice_selected
		
		match choice:
			"cancel":
				exit_action()
				should_continue = false
			"replace project":
				ProjectsJsonAPI.projects.erase(ProjectsJsonAPI.get_project_from_folder(project_folder_name))
			"create new folder":
				var project_folder_name_copy = project_folder_name + " (1)"
				
				var idx = 1
				while ProjectsJsonAPI.check_proj_folder_exists(project_folder_name_copy) == true:
					project_folder_name_copy = project_folder_name + " (" + str(idx) + ")"
					idx += 1
				
				var temp_obj:Project = Project.new(data_json["project_data"])
				temp_obj.project_folder = project_folder_name_copy
				data_json["project_data"] = temp_obj.to_dict()
	
	if should_continue:
		if action_thread != null: action_thread.wait_to_finish()
		
		action_thread = Thread.new()
		action_thread.start(import_project.bind(ProjectsJsonAPI.PROJECTS_FOLDER_PATH, reader, data_json))
		
		var project_object = await finished_action
		
		ProjectsJsonAPI.projects.append(project_object)
		ProjectsJsonAPI.sort_projects()
		ProjectsJsonAPI.save_json()
		
		get_node("%ProjectsListContainer").generate_buttons()
		exit_action()

func import_project(projects_folder:String, reader:ZIPReader, data_json:Dictionary):
	call_deferred("emit_signal", "action_thread_update", "start", {"project": data_json["project_data"]["Name"]})
	
	var project_folder_name = data_json["project_data"]["Path"]
	project_folder_name = project_folder_name.erase(project_folder_name.find("Projects\\"), "Projects\\".length())
	
	var project_location = projects_folder.path_join(project_folder_name)
	
	if DirAccess.dir_exists_absolute(project_location):
		_delete_project(data_json["project_data"]["Name"], project_location)
	
	DirAccess.make_dir_recursive_absolute(project_location)
	
	var files_to_skip = ["data.json", "fileCheck.txt", "exportProjects.json"]
	
	var idx = 0
	for file in files_to_skip: 
		if reader.file_exists(file): idx += 1
	
	for zip_file_name in reader.get_files():
		if files_to_skip.find(zip_file_name) != -1: continue
		
		var file_name
		
		if data_json.version == 0:
			file_name = zip_file_name.erase(zip_file_name.find(project_folder_name), project_folder_name.length())
		else:
			file_name = zip_file_name.erase(zip_file_name.find("project/"), "project/".length())
		
		var file_access = FileAccess.open(project_location.path_join(file_name), FileAccess.WRITE)
		
		call_deferred("emit_signal", "action_thread_update", "import", {
			"size": reader.get_files().size(),
			"idx": idx,
			"file": file_name,
			"project": data_json["project_data"]["Name"]
		})
		
		file_access.store_buffer(reader.read_file(zip_file_name))
		idx += 1
	
	var project_object:Project = Project.new(data_json["project_data"])
	
	call_deferred("emit_signal", "action_thread_update", "finish", {})
	call_deferred("emit_signal", "finished_action", project_object)
	
	reader.close()

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
