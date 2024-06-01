extends Control

const REPLACETEXT:String = "A project with the folder \"%s\" already exists.\nDo you want to replace it?"

@onready var import_dialog := $ImportDialog
@onready var replace_project_confirmation = $ReplaceProjectConfirmation

var import_thread:Thread

signal import_thread_update
signal finished_importing

func _ready():
	import_dialog.canceled.connect(exit_import)
	replace_project_confirmation.add_button("Replace", false, "replace")
	hide()

func begin_import():
	visible = true
	import_dialog.visible = true

func exit_import():
	import_dialog.visible = false
	visible = false

func _on_import_dialog_file_selected(path:String):
	var reader := ZIPReader.new()
	var error := reader.open(path)
	
	if error != OK:
		push_error("Error reading ZIP ", path, " Error Code:", error)
		exit_import()
		return
	
	var data_json = JSON.parse_string(reader.read_file("data.json").get_string_from_ascii())
	
	var project_folder_name = data_json["project_data"]["Path"]
	project_folder_name = project_folder_name.erase(project_folder_name.find("Projects\\"), "Projects\\".length())
	
	# this code is stupid, if theres a way to un-stupid it please let me know
	var should_continue = true
	if ProjectsJsonAPI.get_project_from_folder(project_folder_name) != null:
		replace_project_confirmation.dialog_text = REPLACETEXT % project_folder_name
		replace_project_confirmation.visible = true
		
		var choice = await replace_project_confirmation.choice_selected
		
		match choice:
			"cancel":
				exit_import()
				should_continue = false
			"replace":
				ProjectsJsonAPI.projects.erase(ProjectsJsonAPI.get_project_from_folder(project_folder_name))
			"confirm": # create folder
				var project_folder_name_copy = project_folder_name + " (1)"
				
				var idx = 1
				while ProjectsJsonAPI.get_project_from_folder(project_folder_name_copy) != null:
					project_folder_name_copy = project_folder_name + " (" + str(idx) + ")"
					idx += 1
				
				var temp_obj:Project = Project.new(data_json["project_data"])
				temp_obj.project_folder = project_folder_name_copy
				data_json["project_data"] = temp_obj.to_dict()
	
	if should_continue:
		if import_thread != null: import_thread.wait_to_finish()
		
		import_thread = Thread.new()
		import_thread.start(import_project.bind(ProjectsJsonAPI.PROJECTS_FOLDER_PATH, reader, data_json))
		finished_importing.connect(func(project_object:Project):
			ProjectsJsonAPI.projects.append(project_object)
			ProjectsJsonAPI.sort_projects()
			ProjectsJsonAPI.save_json()
			
			get_node("%ProjectsList").generate_buttons()
			exit_import()
		)

func import_project(projects_folder:String, reader:ZIPReader, data_json:Dictionary):
	call_deferred("emit_signal", "import_thread_update", "start", {})
	
	var project_folder_name = data_json["project_data"]["Path"]
	project_folder_name = project_folder_name.erase(project_folder_name.find("Projects\\"), "Projects\\".length())
	
	var project_location = projects_folder.path_join(project_folder_name)
	
	if DirAccess.dir_exists_absolute(project_location):
		DirAccess.remove_absolute(project_location)
	
	DirAccess.make_dir_recursive_absolute(project_location)
	
	var idx = 1 # this is set to 1 to account for data.json
	for zip_file_name in reader.get_files():
		if zip_file_name == "data.json": continue
		
		var file_name = zip_file_name.erase(zip_file_name.find("project/"), "project/".length())
		var file_access = FileAccess.open(project_location.path_join(file_name), FileAccess.WRITE)
		
		call_deferred("emit_signal", "import_thread_update", "import", {
			"size": reader.get_files().size(),
			"idx": idx,
			"file": file_name
		})
		
		file_access.store_buffer(reader.read_file(zip_file_name))
		idx += 1
	
	var project_object:Project = Project.new(data_json["project_data"])
	
	call_deferred("emit_signal", "import_thread_update", "finish", {})
	call_deferred("emit_signal", "finished_importing", project_object)
	
	reader.close()

func _exit_tree():
	if import_thread != null: import_thread.wait_to_finish()
