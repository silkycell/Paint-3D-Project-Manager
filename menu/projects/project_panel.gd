extends Panel
class_name ProjectPanel

const THUMBNAIL_LOADING = preload("res://menu/projects/thumbnail_loading.tres")

@onready var project_info = $ProjectInfo
@onready var thumbnail = $Thumbnail

var selected_project:Project:
	set(value):
		selected_project = value
		
		project_info.select_project(selected_project)
		
		if selected_project.thumbnail == null:
			thumbnail.texture = THUMBNAIL_LOADING
			await selected_project.thumbnail_finished_loading
		
		thumbnail.texture = selected_project.thumbnail

func _ready():
	if !ProjectsJsonAPI.projects.size(): #ERROR HANDLING!
		push_error("ProjectsJsonAPI.projects is empty!")
		return
	
	selected_project = ProjectsJsonAPI.projects[0]
	
	GlobalSignalHandler.project_selected.connect(func(project):
		selected_project = project
	)
