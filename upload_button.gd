extends Button

@onready var dialog: Panel = %UploadDialog

func _ready():
	focus_mode = Control.FOCUS_NONE
	pressed.connect(func(): dialog.show())
