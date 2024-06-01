extends Panel

@onready var info_label = $InfoLabel
@onready var labelled_progress_bar = $LabelledProgressBar

func _ready():
	hide()

func _on_import_handler_import_thread_update(type, data):
	match type:
		"start":
			info_label.text = "Starting Import..."
			labelled_progress_bar.hide()
			show()
		"import":
			labelled_progress_bar.show()
			
			labelled_progress_bar.max_value = data.size
			labelled_progress_bar.value = data.idx
			info_label.text = data.file
		"finish":
			hide()
