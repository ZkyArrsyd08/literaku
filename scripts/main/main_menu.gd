extends Control

@onready var logo: TextureRect = %Logo
@onready var button_bar: VBoxContainer = %ButtonBar
var sound_button: TextureButton
var sound_mute_slash: Line2D


func _ready() -> void:
	%StartButton.pressed.connect(_open_activities)
	%CollectionButton.pressed.connect(_open_collection)
	%ExitButton.pressed.connect(_quit_game)
	_add_quick_controls()

	for button in [%StartButton, %CollectionButton, %ExitButton]:
		button.mouse_entered.connect(func() -> void: _set_button_scale(button, 1.06))
		button.mouse_exited.connect(func() -> void: _set_button_scale(button, 1.0))

	logo.modulate.a = 0.0
	button_bar.modulate.a = 0.0
	button_bar.scale = Vector2(0.92, 0.92)
	button_bar.pivot_offset = button_bar.size * 0.5
	var enter := create_tween().set_parallel(true)
	enter.tween_property(logo, "modulate:a", 1.0, 0.4)
	enter.tween_property(button_bar, "modulate:a", 1.0, 0.35).set_delay(0.15)
	enter.tween_property(button_bar, "scale", Vector2.ONE, 0.42).set_delay(0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Musik utama langsung jalan; intro Literaku menyusul sekali sesudah menu tampil.
	AudioManager.play_menu_music()
	get_tree().create_timer(0.6).timeout.connect(AudioManager.play_menu_intro)


func _add_quick_controls() -> void:
	var quick_controls := HBoxContainer.new()
	quick_controls.name = "QuickControls"
	quick_controls.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	quick_controls.offset_left = -220.0
	quick_controls.offset_top = 28.0
	quick_controls.offset_right = -32.0
	quick_controls.offset_bottom = 92.0
	quick_controls.add_theme_constant_override("separation", 8)
	add_child(quick_controls)
	quick_controls.add_child(_make_sound_toggle_button())
	quick_controls.add_child(_make_quick_art_button("res://assets/ui/navigation/settings.png", Vector2(64, 64), "Pengaturan suara", _show_sound_settings))


func _make_quick_art_button(texture_path: String, button_size: Vector2, tooltip: String, action: Callable) -> TextureButton:
	var button := TextureButton.new()
	button.custom_minimum_size = button_size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = load(texture_path)
	button.tooltip_text = tooltip
	button.pressed.connect(action)
	button.mouse_entered.connect(func() -> void: _set_button_scale(button, 1.04))
	button.mouse_exited.connect(func() -> void: _set_button_scale(button, 1.0))
	return button


func _make_sound_toggle_button() -> TextureButton:
	sound_button = _make_quick_art_button("res://assets/ui/navigation/sound.png", Vector2(110, 64), "Matikan suara" if AudioManager.sound_enabled else "Nyalakan suara", _toggle_sound)
	sound_mute_slash = Line2D.new()
	sound_mute_slash.points = PackedVector2Array([Vector2(22, 57), Vector2(88, 7)])
	sound_mute_slash.width = 7.0
	sound_mute_slash.default_color = Color("e64545")
	sound_mute_slash.antialiased = true
	sound_mute_slash.visible = not AudioManager.sound_enabled
	sound_button.add_child(sound_mute_slash)
	return sound_button


func _toggle_sound() -> void:
	var is_enabled := AudioManager.toggle_sound()
	sound_mute_slash.visible = not is_enabled
	sound_button.tooltip_text = "Matikan suara" if is_enabled else "Nyalakan suara"


func _show_sound_settings() -> void:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.18, 0.11, 0.22, 0.42)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dimmer)
	var panel := Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-390, -260)
	panel.size = Vector2(780, 520)
	overlay.add_child(panel)
	var art := TextureRect.new()
	art.texture = load("res://assets/ui/settings/sound_settings_panel.png")
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(art)
	var music_slider := _make_volume_slider(AudioManager.music_volume_db, Color("f4c75d"))
	music_slider.position = Vector2(255, 225)
	music_slider.size = Vector2(380, 28)
	music_slider.value_changed.connect(func(value: float) -> void: AudioManager.set_music_volume(value))
	panel.add_child(music_slider)
	var sfx_slider := _make_volume_slider(AudioManager.sfx_volume_db, Color("9dcff7"))
	sfx_slider.position = Vector2(255, 365)
	sfx_slider.size = Vector2(380, 34)
	sfx_slider.value_changed.connect(func(value: float) -> void: AudioManager.set_sfx_volume(value))
	panel.add_child(sfx_slider)
	var close := Button.new()
	close.flat = true
	close.tooltip_text = "Tutup pengaturan suara"
	close.position = Vector2(500, 410)
	close.size = Vector2(245, 80)
	close.pressed.connect(func() -> void: overlay.queue_free())
	panel.add_child(close)


func _make_volume_slider(value: float, accent: Color) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = -40.0
	slider.max_value = 0.0
	slider.step = 1.0
	slider.value = value
	var track := StyleBoxFlat.new()
	track.bg_color = Color("fff1d2")
	track.corner_radius_top_left = 12
	track.corner_radius_top_right = 12
	track.corner_radius_bottom_left = 12
	track.corner_radius_bottom_right = 12
	track.border_color = Color("805035")
	track.set_border_width_all(3)
	var filled := track.duplicate()
	filled.bg_color = accent
	track.content_margin_top = 8
	track.content_margin_bottom = 8
	filled.content_margin_top = 8
	filled.content_margin_bottom = 8
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", filled)
	slider.add_theme_stylebox_override("grabber_area_highlight", filled)
	return slider


func _set_button_scale(button: Control, target_scale: float) -> void:
	button.pivot_offset = button.size * 0.5
	create_tween().tween_property(button, "scale", Vector2.ONE * target_scale, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _open_activities() -> void:
	GameManager.welcome_pending = true
	GameManager.open_screen("activities")


func _open_collection() -> void:
	GameManager.open_screen("collection")


func _quit_game() -> void:
	GameManager.quit_game()
