extends Panel
class_name ProjectPanel

const THUMBNAIL_LOADING = preload("res://menu/projects/assets/thumbnail_loading.tres")

@onready var project_info = $ProjectInfo
@onready var thumbnail = $Thumbnail

var selected_project:Project:
	set(value):
		selected_project = value
		
		project_info.select_project(selected_project)
		
		thumbnail.texture = THUMBNAIL_LOADING
		
		var thumbnail_image = await selected_project.get_thumbnail()
		
		# JIC loading completes after we switched projects
		if selected_project == value:
			thumbnail.texture = thumbnail_image

func _ready():
	if !ProjectsJsonAPI.projects.size(): # ERROR HANDLING!
		push_error("ProjectsJsonAPI.projects is empty!")
		return
	
	selected_project = ProjectsJsonAPI.projects[0]
	
	GlobalSignalHandler.project_selected.connect(func(project):
		selected_project = project
	)
