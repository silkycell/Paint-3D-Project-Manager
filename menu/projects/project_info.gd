extends VBoxContainer

const PROJECT_PATH_TEMPLATE = "Project Path: %s"
const PROJECT_TIME_TEMPLATE = "Last Modified: %s %s"
const PROJECT_SIZE_TEMPLATE = "Size: %s"

@onready var project_name = $ProjectName
@onready var project_path = $ProjectPath
@onready var project_data = $ProjectData
@onready var project_size = $ProjectSize

@onready var recovered_icon = $IconBox/RecoveredIcon
@onready var unsaved_icon = $IconBox/UnsavedIcon

func select_project(project:Project):
	project_name.text = project.name
	project_path.text = PROJECT_PATH_TEMPLATE % project.project_folder
	project_data.text = get_time_string(project)
	project_size.text = PROJECT_SIZE_TEMPLATE % "Loading..."
	
	recovered_icon.visible = project.is_recovered
	unsaved_icon.visible = !project.is_previously_saved
	
	var proj_size = await project.get_size()
	
	# JIC calculation completes after we switched projects
	if project == GlobalSignalHandler.selected_project:
		project_size.text = PROJECT_SIZE_TEMPLATE % String.humanize_size(proj_size)

func get_time_string(project:Project):
	var timezone = Time.get_time_zone_from_system()
	var bias_in_sec = timezone.bias * 60
	
	var date_dict = Time.get_date_dict_from_unix_time(project.timestamp)
	var time_dict = Time.get_time_dict_from_unix_time(project.timestamp + bias_in_sec)
	
	var year = str(date_dict.year).lpad(4, "0")
	var month = str(date_dict.month).lpad(2, "0")
	var day = str(date_dict.day).lpad(2, "0")
	
	var period = ""
	if !SettingsGlobal.use_24_hour:
		period = "AM"
		
		if time_dict.hour >= 12:
			period = "PM"
			time_dict.hour %= 12
	
	var hour = str(time_dict.hour).lpad(2, "0")
	var minute = str(time_dict.minute).lpad(2, "0")
	var second = str(time_dict.second).lpad(2, "0")
	
	var date_string = "%s/%s/%s" % [day, month, year]
	var time_string = "%s:%s:%s %s" % [hour, minute, second, period]
	
	return PROJECT_TIME_TEMPLATE % [date_string, time_string]
