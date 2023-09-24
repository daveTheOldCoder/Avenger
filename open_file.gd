extends Button

@onready var dialog: Window = $%FileDialog

func _ready():
	focus_mode = Control.FOCUS_NONE
	
	# In Web export FileDialog uses server's file system, which is neither
	# desired nor useful.
	if OS.get_name() == "Web":
		disabled = true
		return

	pressed.connect(func(): dialog.show())
