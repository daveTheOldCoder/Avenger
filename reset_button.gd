extends Button

func _ready():
	focus_mode = Control.FOCUS_NONE
	pressed.connect(func(): Events.target_reset.emit())
