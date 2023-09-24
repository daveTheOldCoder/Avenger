extends Label

# This constant must have the same value as the constant with the same name in the specified script.
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

	text = "Godot engine: %s / Export: %s" % [engine_version_info, export_date_time]
