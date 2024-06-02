extends Panel

@onready var info_label = $InfoLabel
@onready var task_label = $TaskLabel
@onready var labelled_progress_bar = $LabelledProgressBar

func _ready():
	get_node("%ImportHandler").import_thread_update.connect(_on_thread_update)
	hide()

func _on_thread_update(type, data):
	match type:
		"start":
			labelled_progress_bar.hide()
			task_label.hide()
			info_label.show()
			show()
			
			info_label.text = "Importing \"%s\"..." % data.project
		"delete":
			labelled_progress_bar.hide()
			task_label.show()
			info_label.show()
			show()
			
			info_label.text = "Importing \"%s\"..." % data.project
			info_label.text = "Deleting old files..."
		"import":
			labelled_progress_bar.show()
			task_label.show()
			info_label.show()
			show()
			
			labelled_progress_bar.max_value = data.size
			labelled_progress_bar.value = data.idx
			
			info_label.text = "Importing \"%s\"..." % data.project
			task_label.text = data.file
		"finish":
			labelled_progress_bar.hide()
			task_label.hide()
			info_label.hide()
			hide()
