extends Panel

@onready var upload_button: Button = $UploadButton
@onready var file_button: Button = $FileButton
@onready var url_button: Button = $UrlButton
@onready var reset_button: Button = $ResetButton
@onready var cancel_button: Button = $CancelButton


func _ready() -> void:

	hide()
	
	upload_button.pressed.connect(_on_button_pressed)
	file_button.pressed.connect(_on_button_pressed)
	url_button.pressed.connect(_on_button_pressed)
	reset_button.pressed.connect(_on_button_pressed)
	cancel_button.pressed.connect(_on_button_pressed)

	upload_button.disabled = (OS.get_name() != "Web")

	# The documentation recommends using call_deferred() for grab_focus().
	# https://docs.godotengine.org/en/4.1/classes/class_control.html#class-control-method-grab-focus
	cancel_button.grab_focus.call_deferred()


func _on_button_pressed() -> void:
	hide()
