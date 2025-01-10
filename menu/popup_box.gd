@tool

extends Panel
class_name PopupBox

@export_category("Options")
@export var title:String = "Title":
	set(value):
		title_label.text = value
		title = value

@export_multiline var text:String = "Text":
	set(value):
		text_label.text = value
		text = value

@export var button_options:Array[String] = ["Yes", "No"]:
	set(value):
		button_options = value
		_regen_buttons()

@export var hide_on_select:bool = true

@export_category("ignore please okay thanks 💖")
@export var button_hbox:HBoxContainer
@export var title_label:Label
@export var text_label:Label

var buttons:Array[Button] = []

signal choice_selected

func _ready():
	_regen_buttons()

func _regen_buttons():
	if button_hbox == null: return
	if buttons == null: buttons = []
	
	for child in button_hbox.get_children():
		child.queue_free()
	
	for button_option in button_options:
		var button = Button.new()
		
		button.text = button_option
		button.size_flags_horizontal = SizeFlags.SIZE_EXPAND_FILL
		
		button.pressed.connect(func():
			choice_selected.emit(button_option.to_lower())
			
			if hide_on_select: hide()
		)
		
		buttons.append(button)
		button_hbox.add_child(button)
