extends Button
class_name ProjectButton

const THUMBNAIL_MISSING = preload("res://menu/projects/thumbnail_missing.png")

@export var label:Label
@export var thumbnail:TextureRect

var project:Project

var thumbnail_thread:Thread

func load(project_to_load:Project):
	project = project_to_load
	label.text = project.name
	
	if project.thumbnail == null:
		await project.thumbnail_finished_loading
	
	thumbnail.texture = project.thumbnail

func _on_pressed():
	GlobalSignalHandler.project_selected.emit(project)
