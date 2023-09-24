extends Button

@onready var dialog: Popup = $%UrlDialog

func _ready():
	focus_mode = Control.FOCUS_NONE
	pressed.connect(func(): dialog._on_about_to_popup(); dialog.show())
