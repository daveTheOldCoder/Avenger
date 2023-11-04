extends Button

@onready var dialog: Window = %CreditsDialog


func _ready():
	dialog.hide()
	pressed.connect(_on_pressed)
	focus_mode = Control.FOCUS_NONE


func _on_pressed() -> void:
	dialog.show()
