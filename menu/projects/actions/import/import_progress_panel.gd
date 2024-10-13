extends ProgressPanel

func _on_thread_update(type, data):
	super(type, data)
	
	match type:
		"start":
			info_label.text = "Importing \"%s\"..." % data.project
		
		"delete":
			_set_visibilities(false, true, true, true)
			
			petri_state = "INDEX"
			info_label.text = "Importing \"%s\"..." % data.project
			info_label.text = "Deleting old files..."
		
		"import":
			_set_visibilities(true, true, true, true)
			
			labelled_progress_bar.max_value = data.size
			labelled_progress_bar.value = data.idx
			
			petri_state = "TRANSFER"
			info_label.text = "Importing \"%s\"..." % data.project
			task_label.text = data.file
