extends FileDialog


func _ready() -> void:
	hide()
#	unresizable = true
	exclusive = true
	always_on_top = true
	mode_overrides_title = false
	title = "Load Target Image"
	filters = PackedStringArray(["*.bmp,*.png,*.jpg,*.jpg,*.jpeg,*.tga,*.webp ; Images"])
	file_mode = FILE_MODE_OPEN_FILE
	access = ACCESS_FILESYSTEM
	file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	var image: Image = Image.load_from_file(path)
	image.resize(128, 128, Image.Interpolation.INTERPOLATE_CUBIC)
	Events.target_changed.emit(ImageTexture.create_from_image(image))
