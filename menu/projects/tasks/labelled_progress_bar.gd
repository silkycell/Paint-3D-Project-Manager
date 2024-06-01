extends ProgressBar
class_name LabelledProgressBar

@onready var progress_label = $ProgressLabel

func _ready():
	changed.connect(func(): _update_label())
	value_changed.connect(func(_value): _update_label())

func _update_label():
	progress_label.text = str(value) + " / " + str(max_value)
