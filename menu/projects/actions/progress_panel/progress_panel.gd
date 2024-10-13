extends Panel
class_name ProgressPanel

@export var parent_action:ActionHandler

@onready var info_label:Label = $InfoLabel
@onready var task_label:Label = $TaskLabel
@onready var labelled_progress_bar:LabelledProgressBar = $LabelledProgressBar

@onready var petri:Control = $AnimationContainer/Petri
@onready var roller:Control = $AnimationContainer/Roller

@onready var petri_animation_player:AnimationPlayer = $AnimationContainer/Petri/AnimationPlayer

var petri_state:String = "HIDDEN":
	set(value):
		if petri_state != value:
			match value:
				"HIDDEN":
					petri.visible = false
					roller.visible = false
					
				"INDEX":
					petri.visible = true
					roller.visible = false
					
					petri_animation_player.play("index")
					
				"TRANSFER":
					petri.visible = true
					roller.visible = true
					
					petri_animation_player.play("walk")
		
		petri_state = value

func _ready():
	if parent_action != null:
		parent_action.action_thread_update.connect(_on_thread_update)
	
	hide()

func _on_thread_update(type, _data):
	match type:
		"start":
			petri_state = "HIDDEN"
			_set_visibilities(false, false, true, true)
		
		"finish":
			petri_state = "HIDDEN"
			_set_visibilities(false, false, false, false)

func _set_visibilities(progress_bar = false, task = false, info = false, this = false):
	labelled_progress_bar.visible = progress_bar
	task_label.visible = task
	info_label.visible = info
	visible = this
