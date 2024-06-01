extends Node

const PROJECTS_FOLDER_PATH_RELATIVE:String = "Packages/Microsoft.MSPaint_8wekyb3d8bbwe/LocalState/Projects"
var LOCAL_APPDATA_PATH:String = OS.get_environment("LocalAppData")
var PROJECTS_FOLDER_PATH:String = LOCAL_APPDATA_PATH.path_join(PROJECTS_FOLDER_PATH_RELATIVE)
var PROJECTS_JSON_PATH = PROJECTS_FOLDER_PATH.path_join("Projects.json")

var projects:Array[Project] = []

func _ready():
	load_json()

func load_json():
	var file_access = FileAccess.open(PROJECTS_JSON_PATH, FileAccess.READ)
	var projects_json_string = file_access.get_as_text()
	
	var projects_json = JSON.new()
	var error = projects_json.parse(projects_json_string)
	if error == OK:
		var parsed_json = projects_json.data
		if typeof(parsed_json) == TYPE_ARRAY:
			for project_data in parsed_json:
				projects.append(Project.new(project_data))
		else:
			push_error("Unexpected data ", typeof(parsed_json))
	else:
		push_error("JSON Parse Error: ", projects_json.get_error_message(), " at line ", projects_json.get_error_line())
	
	sort_projects()

func sort_projects():
	projects.sort_custom(func(a:Project, b:Project):
		return a.date_time > b.date_time
	)

func rebuild_json():
	var projects_json:Array[Dictionary] = []
	
	for project in projects:
		projects_json.append(project.to_dict())
	
	return JSON.stringify(projects_json, "", false, true)

func save_json():
	var file_access = FileAccess.open(PROJECTS_JSON_PATH, FileAccess.WRITE)
	file_access.store_string(rebuild_json())
