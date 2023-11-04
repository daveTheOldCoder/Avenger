extends Button

@onready var dialog: Panel = %LoadDialog

func _ready():
	focus_mode = Control.FOCUS_NONE
	pressed.connect(func(): dialog.show())
