extends Node

@onready var selected_project:Project = ProjectsJsonAPI.projects[0]:
	set(value):
		selected_project = value
		project_selected.emit(selected_project)

signal project_selected
