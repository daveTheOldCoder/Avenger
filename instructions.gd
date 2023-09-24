extends Label

func _ready() -> void:
	show()
	Events.bullet_fired.connect(fade_out)
	Events.no_bullet_fired.connect(fade_in)


# Gradually hide by tweening alpha channel to 0.
func fade_out() -> void:
	get_tree().create_tween().tween_property(self, "modulate:a", 0.0, 1.0)


# Gradually show by tweening alpha channel to 1.
func fade_in() -> void:
	get_tree().create_tween().tween_property(self, "modulate:a", 1.0, 1.0)
