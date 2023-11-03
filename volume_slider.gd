extends HSlider


# Minimum and maximum volume (slider value).
const MIN_VOL: float = 0.0
const MAX_VOL: float = 1.0

# Determined by testing.
const DEFAULT_VOL: float = 0.8

# Minimum and maximum volume (Decibels).
# CAUTION: A MISTAKE HERE COULD DAMAGE AUDIO COMPONENTS.
const MIN_DB: float = -60.0
const MAX_DB: float = 0.0

const SAVE_PATH: String = "user://volume.dat"
const KEY: String =\
		"b9a374181362fc5af06ab5e0508d8ea8a8676bdc10f3629dfa5f109b7fe2478a"


func _ready() -> void:
	
	@warning_ignore("assert_always_true")
	assert(MIN_VOL < MAX_VOL)
	@warning_ignore("assert_always_true")
	assert(MIN_DB < MAX_DB)

	# min_value, max_value and step must be set before value.
	min_value = MIN_VOL
	max_value = MAX_VOL
	step = 0.1
	
	value = DEFAULT_VOL
	editable = true
	tick_count = 11
	ticks_on_borders = true

	value_changed.connect(_on_value_changed)
			
	value = load_volume()

	# Emit signal to initialize volume based on slider value.
	# Use call_deferred() since this in _ready(), and the nodes that receive the
	# signal may not be ready.
	(func(): value_changed.emit(value)).call_deferred()


func _on_value_changed(_value: float) -> void:
	Events.volume_changed.emit(volume_to_db(_value))
	save_volume(_value)

	
# Convert volume in range [MIN_VOL, MAX_VOL] to decibels in range
# [MIN_DB, MAX_DB].
# CAUTION: A MISTAKE HERE COULD DAMAGE AUDIO COMPONENTS.
func volume_to_db(volume: float) -> float:
	var db: float = MIN_DB + volume * (MAX_DB - MIN_DB) / (MAX_VOL - MIN_VOL)
	return clamp(db, MIN_DB, MAX_DB)


# It's mot necessary to clamp the value read from the file here, since it's
# clamped in volume_to_db().
func load_volume() -> float:
	if not FileAccess.file_exists(SAVE_PATH):
		#print_debug("'%s' does not exist" % SAVE_PATH)
		return DEFAULT_VOL

	var err: Error
	
	var file := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, KEY)
	err = OK if file != null else FileAccess.get_open_error()
	if err != OK:
		print_debug("Failed to open '%s' for reading: %d (%s)"\
				% [SAVE_PATH, err, error_string(err)])
		return DEFAULT_VOL

	var _value: float = file.get_float()
	
	file.close()
	
	return _value


func save_volume(_value: float) -> void:
	var file := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, KEY)
	var err: Error = OK if file != null else FileAccess.get_open_error()
	if err != OK:
		print_debug("Failed to open '%s' for writing: %d (%s)"\
				% [SAVE_PATH, err, error_string(err)])
		return

	file.store_float(_value)
	
	file.close()
