extends Button
class_name ProjectButton

const THUMBNAIL_MISSING = preload("res://menu/assets/thumbnail_missing.png")

@export var label:Label
@export var thumbnail:TextureRect

@export var recovered_icon:TextureRect
@export var unsaved_icon:TextureRect

@export var visible_on_screen_notifier:VisibleOnScreenNotifier2D

var project:Project

var thumbnail_thread:Thread

func _ready():
	visible_on_screen_notifier.screen_entered.connect(load_thumbnail)

func load(project_to_load:Project):
	project = project_to_load
	label.text = project.name
	
	recovered_icon.visible = project.is_recovered
	unsaved_icon.visible = !project.is_previously_saved

func load_thumbnail():
	thumbnail.texture = await project.get_thumbnail()

func _on_pressed():
	GlobalSignalHandler.selected_project = project
