extends RichTextLabel

func _ready():
	meta_clicked.connect(open_url)

static func open_url(url:String):
	OS.shell_open(url)
