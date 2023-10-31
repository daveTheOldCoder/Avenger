extends AudioStreamPlayer

@onready var file_dialog: FileDialog = %FileDialog
@onready var url_dialog: Popup = %UrlDialog
@onready var upload_dialog: Control = %UploadDialog


func _ready() -> void:
	Events.volume_changed.connect(func(v: float): volume_db = v)
	playing = true


func _process(_delta) -> void:
	stream_paused = file_dialog.visible or url_dialog.visible\
			or upload_dialog.visible
