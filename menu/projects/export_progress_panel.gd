extends Panel

@onready var info_label = $InfoLabel
@onready var labelled_progress_bar = $LabelledProgressBar

func _ready():
	hide()

func _on_export_handler_export_thread_update(type, data):
	match type:
		"start":
			labelled_progress_bar.hide()
			show()
		"index":
			info_label.text = "Indexing Files... " + str(data.count)
		"write":
			labelled_progress_bar.show()
			
			labelled_progress_bar.max_value = data.size
			labelled_progress_bar.value = data.idx
			info_label.text = data.file
		"finish":
			hide()
