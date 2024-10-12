extends Panel
class_name ProjectPanel

const THUMBNAIL_LOADING = preload("res://menu/projects/assets/thumbnail_loading.tres")

@onready var project_info = $ProjectInfo
@onready var thumbnail = $Thumbnail

var selected_project:Project:
	get():
		return GlobalSignalHandler.selected_project

func _ready():
	if !ProjectsJsonAPI.projects.size(): # ERROR HANDLING!
		push_error("ProjectsJsonAPI.projects is empty!")
		return
	
	GlobalSignalHandler.project_selected.connect(load_project)
	load_project(GlobalSignalHandler.selected_project)

func load_project(project):
	project_info.select_project(selected_project)
	
	thumbnail.texture = THUMBNAIL_LOADING
	var thumbnail_image = await selected_project.get_thumbnail()
	
	# JIC loading completes after we switched projects
	if selected_project == project:
		thumbnail.texture = thumbnail_image
