extends ConfirmationDialog
class_name CustomConfirmationDialog

signal choice_selected

func _ready():
	canceled.connect(_on_canceled)
	confirmed.connect(_on_confirmed)
	custom_action.connect(_on_custom_action)

func _on_canceled():
	choice_selected.emit("cancel")
	hide()

func _on_confirmed():
	choice_selected.emit("confirm")
	hide()

func _on_custom_action(action):
	choice_selected.emit(action)
	hide()
