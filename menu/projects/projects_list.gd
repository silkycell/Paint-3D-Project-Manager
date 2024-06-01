extends ScrollContainer
class_name ProjectsList

const PROJECT_BUTTON = preload("res://menu/projects/project_button.tscn")

@onready var v_box = $VBoxContainer

func _ready():
	generate_buttons()

func generate_buttons():
	for child in v_box.get_children():
		child.queue_free()
	
	for project in ProjectsJsonAPI.projects:
		var button = PROJECT_BUTTON.instantiate()
		button.load(project)
		v_box.add_child(button)
