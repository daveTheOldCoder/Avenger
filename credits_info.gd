extends RichTextLabel

const VERSION_SCRIPT_PATH: String = "res://addons/export_version/version.gd"


func _ready() -> void:

	var engine_version_info: String = Engine.get_version_info()['string']
	var export_date_time: String

	if ResourceLoader.exists(VERSION_SCRIPT_PATH):
		var resource: Resource = ResourceLoader.load(VERSION_SCRIPT_PATH)
		if resource != null:
			export_date_time = resource.VERSION
		else:
			export_date_time = "Failed to load resource: %s" % VERSION_SCRIPT_PATH
	else:
		export_date_time = "Resource does not exist: %s" % VERSION_SCRIPT_PATH

	text ="AVENGER - by DaveTheCoder\n"\
		+ "\n"\
		+ "Version: %s\n" % export_date_time\
		+ "\n"\
		+ "[url=http://godotengine.org/license]Godot Engine[/url]: %s\n" % engine_version_info\
		+ "\n"\
		+ "Background music:\n"\
		+ "\"Endless Robot Runner\"\n"\
		+ "by Eric Matyas\n"\
		+ "[url=http://www.soundimage.org]www.soundimage.org[/url]\n"\
		+ "\n"\
		+ "Copyright © 2023 - All rights reserved."

	meta_clicked.connect(func(url: String): OS.shell_open(url))
