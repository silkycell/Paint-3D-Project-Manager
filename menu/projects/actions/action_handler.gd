extends Control
class_name ActionHandler

const POPUP_BOX = preload("res://menu/popup_box.tscn")

var selected_project:Project
var action_thread:Thread

signal action_thread_update
signal finished_action

func _ready():
	hide()

func begin_action(project:Project = null):
	visible = true
	selected_project = project

func exit_action():
	visible = false
	selected_project = null

func display_popup(title:String, text:String, options:Array[String] = ["Ok"]):
	var popup_box = POPUP_BOX.instantiate()
	popup_box.title = title
	popup_box.text = text
	
	# this shit KEEPS ERRORING if i ASSIGN and IDK WHY!!!!
	popup_box.button_options.clear()
	
	for option in options:
		popup_box.button_options.append(option)
	
	add_child(popup_box)
	
	return popup_box.choice_selected

func display_error(title:String, content:String):
	await display_popup(title, content)
	exit_action()

# lazy functions
func display_error_deferred(title:String, text:String):
	call_deferred("display_error", title, text)

func display_popup_deferred(title:String, text:String, options:Array[String] = ["Ok"]):
	call_deferred("display_popup", title, text, options)

func _exit_tree():
	if action_thread != null: action_thread.wait_to_finish()
