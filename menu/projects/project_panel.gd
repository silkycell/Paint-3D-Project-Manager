extends Panel
class_name ProjectPanel

const THUMBNAIL_LOADING = preload("res://menu/projects/thumbnail_loading.png")

@onready var project_name = $ProjectName
@onready var thumbnail = $Thumbnail

var selected_project:Project:
	set(value):
		selected_project = value
		
		project_name.text = selected_project.name
		
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
