extends Panel

var http_request: HTTPRequest = HTTPRequest.new()
var http_header_regex: RegEx = RegEx.new()
var message_flasher: Timer = Timer.new()

@onready var url: LineEdit = $Url
@onready var url_btn: Button = $UrlBtn
@onready var preview: Sprite2D = $ImagePreview
@onready var message: Label = $Message
@onready var ok_btn: Button = $OkBtn
@onready var cancel_btn: Button = $CancelBtn


func _ready() -> void:

	hide()
	url.virtual_keyboard_enabled = true
	url.virtual_keyboard_type = url.VirtualKeyboardType.KEYBOARD_TYPE_URL
	url.placeholder_text = "Enter image URL here."
	visibility_changed.connect(_on_visibility_changed)
	url.text_changed.connect(func(s: String): url_btn.disabled = s.is_empty())
	url_btn.pressed.connect(func():\
			message.text = "Fetching..."; fetch_url(url.text.strip_edges()))
	ok_btn.pressed.connect(func():\
			Events.target_changed.emit(preview.texture); hide())
	cancel_btn.pressed.connect(func(): hide())

	http_request.timeout = 10.0
	http_request.use_threads = true
	http_request.process_mode = PROCESS_MODE_ALWAYS
	http_request.request_completed.connect(_http_request_completed)
	add_child(http_request)

	message_flasher.wait_time = 1.0	
	message_flasher.one_shot = false
	message_flasher.autostart = false
	message_flasher.timeout.connect(func():\
			message.modulate.a = 1.0 if message.modulate.a < 0.75 else 0.5)
	add_child(message_flasher)

	# Compile RegEx pattern for parsing a single HTTP header.
	var regex_err: Error = http_header_regex.compile(
		# Anchor to start of string.
		"^"
		# Capture group 1
		# Header name: one or more non-whitespace characters.
		+ "(\\S+)"
		# Colon separating header name and value.
		+ ":"
		# Optional whitespace.
		+ "\\s*"
		# Capture group 2
		# Header value: a string starting and ending with non-whitespace.
		+ "(\\S.*\\S)"
		# Anchor to end of string.
		+ "$"
	)
	assert(regex_err == OK)


func _on_visibility_changed() -> void:
	if visible:
		url.text = ""
		url_btn.disabled = true
		preview.texture = null
		message.text = ""
		ok_btn.disabled = true
		message_flasher.start()


func _on_hide() -> void:
	http_request.cancel_request()
	message_flasher.stop()


func fetch_url(_url: String) -> void:

	var url_lower: String = _url.to_lower()
	if not (url_lower.begins_with("http://")\
			or url_lower.begins_with("https://")):
		message.text = "URL must begin with http:// or https://"
		return

	# Perform the request.
	var error: Error = http_request.request(_url)

	if error != OK:
		# HTTP request error.
		print_debug("HTTP request error: %d" % error)


# Called when the HTTP request is completed.
@warning_ignore("unused_parameter")
func _http_request_completed(result: int, response_code: int,
		headers: PackedStringArray, body: PackedByteArray) -> void:
#	print_debug("result=%d, response_code=%d, headers=%s, body=%s" %\
#			[result, response_code, headers, body])
	if result != HTTPRequest.RESULT_SUCCESS:
		print_debug("result=", result)
		message.text = "Failed to fetch content: %d" % result
		return

	var content_type: String = ""
	var content_length: int = -1
	for header in headers:
#		print_debug("header=", header)
		var reg_ex_match: RegExMatch = http_header_regex.search(header)
		if reg_ex_match != null:
#				print_debug("regex group 1: '%s'" % reg_ex_match.strings[1])
			if reg_ex_match.strings[1].nocasecmp_to("Content-Type") == 0:
				content_type = reg_ex_match.strings[2]
			if reg_ex_match.strings[1].nocasecmp_to("Content-Length") == 0:
				content_length = int(reg_ex_match.strings[2])
	print_debug("content_type=%s, content_length=%d" % [content_type, content_length])

	if not ["image/bmp","image/jpeg","image/png","image/x-targa","image/webp"]\
			.has(content_type.to_lower()):
		message.text = "Fetched content does not contain supported image type."
		return
			
	if content_length < 0:
		message.text = "Fetched content size is unknown."
		return
	
	if content_length > 250000:
		message.text = "Fetched content size exceeds supported image size."
		return
	
	var image: Image = Image.new()
	var err: Error
	match content_type.to_lower():
		"image/bmp":
			err = image.load_bmp_from_buffer(body)
		"image/jpeg":
			err = image.load_jpg_from_buffer(body)
		"image/png":
			err = image.load_png_from_buffer(body)
		"image/x-targa":
			err = image.load_tga_from_buffer(body)
		"image/webp":
			err = image.load_webp_from_buffer(body)
		_:
			# This case should never occur, since content_type was checked above.
			message.text = "Fetched content does not contain supported image type."
			return
			
	if err != OK:
		print_debug("err=", err)
		message.text = "Failed to load image from fetched content: %d" % err
		return

	message.text = "Image fetched."
	image.resize(128, 128, Image.Interpolation.INTERPOLATE_CUBIC)
	preview.texture = ImageTexture.create_from_image(image)
	ok_btn.disabled = false
