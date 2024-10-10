extends Object
class_name Project

const THUMBNAIL_MISSING = preload("res://menu/projects/assets/thumbnail_missing.png")

var ID:String = ""
var source_ID:String = ""
var name:String = ""
var URI:String = ""
var date_time:float = 0
var path:String = ""
var source_file_path:String = ""
var version:float = 0
var is_recovered:bool = false
var is_previously_saved:bool = false

var timestamp:float:
	get:
		return (date_time - 116444736000000000) / 10000000
	set(value):
		date_time = 10000000 * value + 116444736000000000

var project_folder:String = "":
	get:
		return path.erase(path.find("Projects\\"), "Projects\\".length())
	set(value):
		path = "Projects\\" + value
		URI = "ms-appdata:///local/Projects/" + value + "/Thumbnail.png"
		project_folder = value

var absolute_project_folder:String:
	get:
		return ProjectsJsonAPI.PROJECTS_FOLDER_PATH.path_join(project_folder)

var size_thread:Thread
var size:float = -INF:
	get:
		if size == -INF && size_thread == null:
			size_thread = Thread.new()
			size_thread.start(_calculate_size.bind(absolute_project_folder), Thread.PRIORITY_LOW)
		
		return size

var thumbnail_thread:Thread
var thumbnail:Texture2D = null

func _init(project_data:Dictionary):
	ID = project_data.get("Id")
	source_ID = project_data.get("SourceId")
	name = project_data.get("Name")
	URI = project_data.get("URI")
	date_time = float(project_data.get("DateTime"))
	path = project_data.get("Path")
	source_file_path = project_data.get("SourceFilePath")
	version = float(project_data.get("Version"))
	is_recovered = bool(project_data.get("IsRecovered"))
	is_previously_saved = bool(project_data.get("IsPreviouslySaved"))
	
	thumbnail_thread = Thread.new()
	thumbnail_thread.start(_load_thumbnail.bind(get_thumbnail_path()), Thread.PRIORITY_LOW)
	
	thumbnail_finished_loading.connect(func(thumbnail_texture):
		thumbnail = thumbnail_texture
	)
	
	size_finished_calculating.connect(func(calculated_size):
		size = calculated_size
	)

signal thumbnail_finished_loading
func _load_thumbnail(thumbnail_path):
	if !FileAccess.file_exists(thumbnail_path):
		call_deferred("emit_signal", "thumbnail_finished_loading", THUMBNAIL_MISSING)
		return
	
	var file_access = FileAccess.open(thumbnail_path, FileAccess.READ)
	var buffer = file_access.get_buffer(file_access.get_length())
	var image = Image.new()
	var error = image.load_png_from_buffer(buffer)
	
	if error != OK:
		push_warning("Unable to load ", thumbnail_path, " Error Code:", error)
		call_deferred("emit_signal", "thumbnail_finished_loading", THUMBNAIL_MISSING)
		return
	
	var texture = ImageTexture.create_from_image(image)
	call_deferred("emit_signal", "thumbnail_finished_loading", texture)

func get_thumbnail_path():
	var image_path:String = ""
	
	if URI.find("ms-appdata:///local/Projects/") == -1:
		image_path = absolute_project_folder.path_join("Thumbnail.png")
	else:
		var uri_path = URI.erase(URI.find("ms-appdata:///local/Projects/"), "ms-appdata:///local/Projects/".length())
		image_path = ProjectsJsonAPI.PROJECTS_FOLDER_PATH.path_join(uri_path)
	
	return image_path

signal size_finished_calculating
func _calculate_size(folder):
	var dir_access = DirAccess.open(folder)
	
	if dir_access == null:
		call_deferred("emit_signal", "size_finished_calculating", -1)
		push_warning("Error accessing project dir while getting size, Error Code: ", DirAccess.get_open_error())
		return -1
	
	var total_size = 0
	for file_name in dir_access.get_files():
		var file_access = FileAccess.open(folder.path_join(file_name), FileAccess.READ)
		
		if file_access == null:
			call_deferred("emit_signal", "size_finished_calculating", -1)
			push_warning("Error accessing file while getting size, Error Code: ", FileAccess.get_open_error())
			return -1
		
		total_size += file_access.get_length()
		
		file_access.close()
	
	call_deferred("emit_signal", "size_finished_calculating", total_size)

func to_dict():
	return {
		"Id": ID,
		"SourceId": source_ID,
		"Name": name,
		"URI": URI,
		"DateTime": date_time,
		"Path": path,
		"SourceFilePath": source_file_path,
		"Version": version,
		"IsRecovered": is_recovered,
		"IsPreviouslySaved": is_previously_saved
	}
