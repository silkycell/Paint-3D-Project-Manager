extends Control

@onready var import_dialog = $ImportDialog

var import_thread:Thread

signal import_thread_update
signal finished_importing

func _ready():
	import_dialog.canceled.connect(exit_import)
	hide()

func begin_import():
	visible = true
	import_dialog.visible = true

func exit_import():
	import_dialog.visible = false
	visible = false

func _on_import_dialog_file_selected(path:String):
	if import_thread != null: import_thread.wait_to_finish()
	
	import_thread = Thread.new()
	import_thread.start(import_project.bind(path, ProjectsJsonAPI.PROJECTS_FOLDER_PATH))
	finished_importing.connect(func(project_object:Project):
		ProjectsJsonAPI.projects.append(project_object)
		ProjectsJsonAPI.sort_projects()
		ProjectsJsonAPI.save_json()
		
		get_node("%ProjectsList").generate_buttons()
		exit_import()
	)

func import_project(path:String, projects_folder:String):
	call_deferred("emit_signal", "import_thread_update", "start", {})
	
	var reader := ZIPReader.new()
	var err := reader.open(path)
	
	if err != OK:
		push_error(err)
		return
	
	var data_json = JSON.parse_string(reader.read_file("data.json").get_string_from_ascii())
	
	var project_folder_name = data_json["project_data"]["Path"]
	project_folder_name = project_folder_name.erase(project_folder_name.find("Projects\\"), "Projects\\".length())
	
	var project_location = projects_folder.path_join(project_folder_name)
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
