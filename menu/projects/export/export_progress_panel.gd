extends Panel

@onready var info_label = $InfoLabel
@onready var task_label = $TaskLabel
@onready var labelled_progress_bar = $LabelledProgressBar

func _ready():
	hide()

func _on_export_handler_export_thread_update(type, data):
	match type:
		"start":
			labelled_progress_bar.hide()
			task_label.hide()
			info_label.show()
			show()
			
			info_label.text = "Exporting \"%s\"..." % data.project
		"index":
			labelled_progress_bar.hide()
			task_label.show()
			info_label.show()
			show()
			
			info_label.text = "Exporting \"%s\"..." % data.project
			task_label.text = "Indexing Files... (" + str(data.count) + ")"
		"write":
			labelled_progress_bar.show()
			task_label.show()
			info_label.show()
			show()
			
			labelled_progress_bar.max_value = data.size
			labelled_progress_bar.value = data.idx
			
			info_label.text = "Exporting \"%s\"..." % data.project
			task_label.text = data.file
		"finish":
			labelled_progress_bar.hide()
			task_label.hide()
			info_label.hide()
			hide()
