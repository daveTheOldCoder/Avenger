# Uses asset:
#	File Access Web 1.1
#	https://godotengine.org/asset-library/asset/2118

extends Panel

var message_flasher: Timer = Timer.new()

@onready var upload_button: Button = $UploadButton
@onready var preview_frame: ColorRect = $PreviewFrame
@onready var preview: Sprite2D = $ImagePreview
@onready var message: Label = $Message
@onready var file_name: Label = $FileName
@onready var file_size: Label = $FileSize
@onready var cancel_btn: Button = $CancelBtn
@onready var ok_btn: Button = $OkBtn

var file_access_web: FileAccessWeb = FileAccessWeb.new()

const IMAGE_TYPE: String = ".bmp,.jpg,.png,.tga,.webp"


func _ready() -> void:

	hide()
	visibility_changed.connect(_on_visibility_changed)
	ok_btn.pressed.connect(func():\
			Events.target_changed.emit(preview.texture); _hide())
	cancel_btn.pressed.connect(func(): _hide())

	message_flasher.wait_time = 1.0	
	message_flasher.one_shot = false
	message_flasher.autostart = false
	message_flasher.timeout.connect(func():\
			message.modulate.a = 1.0 if message.modulate.a < 0.75 else 0.5)
	add_child(message_flasher)

	upload_button.pressed.connect(_on_upload_pressed)
	file_access_web.loaded.connect(_on_file_loaded)
	file_access_web.progress.connect(_on_progress)


func _on_visibility_changed() -> void:
	if visible:
		preview.texture = null
		message.text = "Uploaded image will be resized to %d x %d pixels."\
				% [preview_frame.size.x, preview_frame.size.y]
		file_name.text = ""
		file_size.text = ""
		ok_btn.disabled = true
		message_flasher.start()


func _hide() -> void:
	message_flasher.stop()
	hide()


func _on_upload_pressed() -> void:
	preview.texture = null
	message.text = ""
	file_name.text = ""
	file_size.text = ""
	file_access_web.open(IMAGE_TYPE)


func _on_progress(current_bytes: int, total_bytes: int) -> void:
	var percentage: float = float(current_bytes) / float(total_bytes) * 100
	message.text = "Uploading... %.1f%" % percentage


func _on_file_loaded(_file_name: String, type: String, base64_data: String) -> void:
	file_name.text = _file_name
	var raw_data: PackedByteArray = Marshalls.base64_to_raw(base64_data)
	raw_draw(type, raw_data)


func raw_draw(type: String, data: PackedByteArray) -> void:
	var image := Image.new()
	var error: Error = _load_image(image, type, data)

	if error == OK:
		preview.texture = _create_texture_from(image)
		ok_btn.disabled = false
	else:
		var msg: String = "Error %d: %s" % [error, error_string(error)]
		message.text = msg
		push_error(msg)


func _load_image(image: Image, type: String, data: PackedByteArray) -> Error:
	match type:
		"image/bmp":
			return image.load_bmp_from_buffer(data)
		"image/jpeg":
			return image.load_jpg_from_buffer(data)
		"image/png":
			return image.load_png_from_buffer(data)
		"image/webp":
			return image.load_webp_from_buffer(data)
		"image/x-targa":
			return image.load_tga_from_buffer(data)
		_:
			return Error.FAILED


func _create_texture_from(image: Image) -> ImageTexture:
	file_size.text = "%d bytes" % image.get_data().size()
	image.resize(128, 128, Image.Interpolation.INTERPOLATE_CUBIC)
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture
