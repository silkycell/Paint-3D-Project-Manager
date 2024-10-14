extends LineEdit

@onready var scroll_container = %ProjectsListContainer

var v_box:VBoxContainer:
	get():
		return scroll_container.v_box

func _on_text_changed(new_text):
	for _button in v_box.get_children():
		var button:ProjectButton = _button
		
		if new_text.is_empty():
			button.visible = true
		else:
			button.visible = button.project.name.containsn(new_text)
