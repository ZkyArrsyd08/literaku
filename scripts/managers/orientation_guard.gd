extends CanvasLayer

# Di HP (web, layar sentuh) yang masih portrait: game di-pause dan muncul arahan
# animasi HP berputar ke landscape. Setelah HP landscape, game langsung jalan.

const CHECK_INTERVAL := 0.2

var _overlay: Control
var _phone: Control
var _tween: Tween
var _timer := 0.0
var _is_touch_device := false
var _showing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 128
	if not OS.has_feature("web"):
		set_process(false)
		return
	_is_touch_device = _js_flag("(navigator.maxTouchPoints > 0 && window.matchMedia('(pointer: coarse)').matches) ? 1 : 0")
	if not _is_touch_device:
		set_process(false)
		return
	_build_overlay()
	_update()


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= CHECK_INTERVAL:
		_timer = 0.0
		_update()


func _update() -> void:
	var portrait := _js_flag("(window.innerHeight > window.innerWidth) ? 1 : 0")
	if portrait and not _showing:
		_show_overlay()
	elif not portrait and _showing:
		_hide_overlay()


func _js_flag(expression: String) -> bool:
	var result = JavaScriptBridge.eval(expression)
	if result == null:
		return false
	return int(result) == 1


func _show_overlay() -> void:
	_showing = true
	AudioManager.stop_audio()
	get_tree().paused = true
	_overlay.visible = true
	_start_animation()


func _hide_overlay() -> void:
	_showing = false
	_overlay.visible = false
	if _tween != null:
		_tween.kill()
		_tween = null
	get_tree().paused = false


func _start_animation() -> void:
	if _tween != null:
		_tween.kill()
	_phone.rotation_degrees = 0.0
	_tween = create_tween().set_loops()
	_tween.tween_interval(0.5)
	_tween.tween_property(_phone, "rotation_degrees", -90.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(1.0)
	_tween.tween_property(_phone, "rotation_degrees", 0.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func _build_overlay() -> void:
	_overlay = ColorRect.new()
	(_overlay as ColorRect).color = Color(0.13, 0.16, 0.36, 1.0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.visible = false
	add_child(_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var box := VBoxContainer.new()
<<<<<<< HEAD
	box.add_theme_constant_override("separation", 48)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(box)

	# Wadah persegi supaya HP bisa berputar tanpa menggeser teks; dipusatkan di tengah.
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(460, 460)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(holder)

	_phone = Panel.new()
	_phone.custom_minimum_size = Vector2(220, 380)
	_phone.size = Vector2(220, 380)
	_phone.position = Vector2(120, 40)
	_phone.pivot_offset = Vector2(110, 190)
	_phone.add_theme_stylebox_override("panel", _style(Color(1, 1, 1), 44, Color(1.0, 0.78, 0.34), 14))
	holder.add_child(_phone)

	var screen := Panel.new()
	screen.position = Vector2(20, 44)
	screen.size = Vector2(180, 282)
	screen.add_theme_stylebox_override("panel", _style(Color(0.36, 0.78, 1.0), 20, Color(0, 0, 0, 0), 0))
=======
	box.add_theme_constant_override("separation", 28)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(box)

	# Wadah persegi supaya HP bisa berputar tanpa menggeser teks.
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(260, 260)
	box.add_child(holder)

	_phone = Panel.new()
	_phone.custom_minimum_size = Vector2(110, 190)
	_phone.size = Vector2(110, 190)
	_phone.position = Vector2(75, 35)
	_phone.pivot_offset = Vector2(55, 95)
	_phone.add_theme_stylebox_override("panel", _style(Color(1, 1, 1), 22, Color(1.0, 0.78, 0.34), 7))
	holder.add_child(_phone)

	var screen := Panel.new()
	screen.position = Vector2(10, 22)
	screen.size = Vector2(90, 140)
	screen.add_theme_stylebox_override("panel", _style(Color(0.36, 0.78, 1.0), 10, Color(0, 0, 0, 0), 0))
>>>>>>> origin/main
	_phone.add_child(screen)

	var letters := Label.new()
	letters.text = "Aa"
	letters.set_anchors_preset(Control.PRESET_FULL_RECT)
	letters.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letters.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
<<<<<<< HEAD
	letters.add_theme_font_size_override("font_size", 84)
=======
	letters.add_theme_font_size_override("font_size", 38)
>>>>>>> origin/main
	letters.add_theme_color_override("font_color", Color(1, 1, 1))
	screen.add_child(letters)

	var title := Label.new()
	title.text = "Putar HP kamu ke mode landscape"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
<<<<<<< HEAD
	title.custom_minimum_size = Vector2(1000, 0)
	title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title.add_theme_font_size_override("font_size", 78)
=======
	title.custom_minimum_size = Vector2(560, 0)
	title.add_theme_font_size_override("font_size", 40)
>>>>>>> origin/main
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	box.add_child(title)

	var hint := Label.new()
	hint.text = "Biar kamu bisa mulai bermain"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
<<<<<<< HEAD
	hint.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hint.add_theme_font_size_override("font_size", 54)
=======
	hint.add_theme_font_size_override("font_size", 28)
>>>>>>> origin/main
	hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.5))
	box.add_child(hint)


func _style(fill: Color, radius: int, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(radius)
	style.border_color = border
	style.set_border_width_all(border_width)
	return style
