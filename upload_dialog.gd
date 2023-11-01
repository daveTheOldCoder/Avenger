# Uses asset:
#	File Access Web 1.1
#	https://godotengine.org/asset-library/asset/2118

extends Panel

var message_flasher: Timer = Timer.new()

@onready var url: Label = $Url
@onready var upload_button: Button = $UrlBtn
@onready var preview: Sprite2D = $ImagePreview
@onready var message: Label = $Message
@onready var ok_btn: Button = $OkBtn
@onready var cancel_btn: Button = $CancelBtn

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
		print_debug("showing")
		preview.texture = null
		message.text = ""
		ok_btn.disabled = true
		message_flasher.start()


func _hide() -> void:
	print_debug("hiding")
	message_flasher.stop()
	hide()


func _on_upload_pressed() -> void:
	message.text = "Uploading..."
	file_access_web.open(IMAGE_TYPE)


func _on_progress(current_bytes: int, total_bytes: int) -> void:
	var percentage: float = float(current_bytes) / float(total_bytes) * 100
	message.text = "Uploading... %.1f%" % percentage


func _on_file_loaded(_file_name: String, type: String, base64_data: String) -> void:
	url.text = _file_name
	var raw_data: PackedByteArray = Marshalls.base64_to_raw(base64_data)
	raw_draw(type, raw_data)


func raw_draw(type: String, data: PackedByteArray) -> void:
	var image := Image.new()
	var error: Error = _load_image(image, type, data)

	if error == OK:
		preview.texture = _create_texture_from(image)
		ok_btn.disabled = false
	else:
		message.text = "Error %s" % error
		push_error("Error %s" % error)


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
	message.text = "Image size: %d bytes" % image.get_data().size()
	image.resize(128, 128, Image.Interpolation.INTERPOLATE_CUBIC)
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture
