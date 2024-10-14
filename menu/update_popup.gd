extends Button

const TEMPLATE_TEXT:String = "v%s is avaliable to download\nClick here to open the download page"
const REPO = 'silkycell/Paint-3D-Project-Manager'

@onready var info = $Info
@onready var http_request = $HTTPRequest
@onready var close = $Close

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	
	hide()
	close.pressed.connect(queue_free)
	pressed.connect(func():
		OS.shell_open('https://github.com/%s/releases/latest' % REPO)
		queue_free()
	)
	
	http_request.request('https://api.github.com/repos/%s/releases/latest' % REPO)

func _on_request_completed(_result, response_code, _headers, body):
	if body.is_empty(): return
	if response_code == 404: return
	
	var json:Dictionary = JSON.parse_string(body.get_string_from_utf8())
	
	if !json.has("tag_name"): return
	
	var current_ver = ProjectSettings.get_setting("application/config/version")
	var github_ver = json.tag_name
	
	var compare_result = compare_versions(current_ver, github_ver)
	
	if compare_result == -1:
		_show_message(github_ver)
	else:
		queue_free()

func _show_message(new_version:String):
	info.text = TEMPLATE_TEXT % new_version
	show()

# thanks google gemini lmfao
func compare_versions(version1, version2):
	# Split version numbers into components
	var version1_components = version1.split(".")
	var version2_components = version2.split(".")
	
	# Compare components until a difference is found or all components are equal
	for i in range(min(version1_components.size(), version2_components.size())):
		if int(version1_components[i]) > int(version2_components[i]):
			return 1  # Version 1 is greater
		elif int(version1_components[i]) < int(version2_components[i]):
			return -1  # Version 2 is greater
	
	# If all components are equal, compare lengths to determine if one version is a subset of the other
	if version1_components.size() > version2_components.size():
		return 1  # Version 1 is greater
	elif version1_components.size() < version2_components.size():
		return -1  # Version 2 is greater
	
	# If all components are equal and the lengths are the same, the versions are equal
	return 0  # Versions are equal
