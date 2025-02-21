extends Control

@onready var tos_popup = $TOSPopup

func _ready():
	tos_popup.choice_selected.connect(func(_choice):
		queue_free()
	)
