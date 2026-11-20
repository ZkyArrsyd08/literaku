class_name TracingCanvas
extends Control

signal completed
var guide: Array = []
var stroke_index := 0
var current := PackedVector2Array()
var trails: Array[PackedVector2Array] = []
var drawing := false
var practice_stage := 2
var preview_time := 0.0
# Aset garis putus-putus (hanya huruf kapital). Bila tidak ada, jalur bawaan dipakai.
const ASSET_PATH := "res://assets/ui/alphabet/dashed/%s.png"
# Aset garis putus-putus huruf kecil. Bila tidak ada (misalnya x.png), jalur bawaan dipakai.
const ASSET_PATH_LOWER := "res://assets/ui/tracing/lowercase/%s.png"
const ASSET_REFERENCE_SIZE := Vector2(311, 256)
const ASSET_SECONDS_PER_STROKE := 1.8
var asset_texture: Texture2D = null


func set_letter(letter: String, letter_case: String, stage := 2) -> void:
	asset_texture = null
	var asset_guide: Array = []
	if letter_case == "upper":
		var asset_path := ASSET_PATH % letter.to_upper()
		if ResourceLoader.exists(asset_path):
			var loaded: Variant = load(asset_path)
			if loaded is Texture2D:
				asset_texture = loaded
				asset_guide = TracingData.asset_strokes(letter)
	elif letter_case == "lower":
		var lower_path := ASSET_PATH_LOWER % letter.to_lower()
		if ResourceLoader.exists(lower_path):
			var loaded_lower: Variant = load(lower_path)
			if loaded_lower is Texture2D:
				asset_texture = loaded_lower
				asset_guide = TracingLowercaseData.strokes(letter)
	if asset_texture != null and not asset_guide.is_empty():
		guide = asset_guide
	else:
		asset_texture = null
		guide = TracingData.strokes(letter, letter_case)
	practice_stage = stage
	queue_redraw()


# Gambar aset dipasang di tengah kanvas dengan skala yang sama untuk semua huruf.
func _asset_rect() -> Rect2:
	var draw_scale := minf(size.x * 0.94 / ASSET_REFERENCE_SIZE.x, size.y * 0.94 / ASSET_REFERENCE_SIZE.y)
	var draw_size := asset_texture.get_size() * draw_scale
	return Rect2((size - draw_size) * 0.5, draw_size)


# Mengubah titik jalur (0..1) menjadi posisi piksel pada kanvas.
func _to_canvas(point: Vector2) -> Vector2:
	if asset_texture != null:
		var rect := _asset_rect()
		return rect.position + point * rect.size
	return point * size


func _process(delta: float) -> void:
	if practice_stage == 1:
		preview_time += delta
		queue_redraw()


func clear() -> void:
	stroke_index = 0
	current = PackedVector2Array()
	trails.clear()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var point := Vector2.ZERO
	var pressed := false
	var released := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		point = event.position; pressed = event.pressed; released = not event.pressed
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		point = event.position
	elif event is InputEventScreenTouch:
		point = event.position; pressed = event.pressed; released = not event.pressed
	elif event is InputEventScreenDrag:
		point = event.position
	else:
		return
	if pressed:
		drawing = true; current = PackedVector2Array([point])
	elif drawing and not released:
		current.append(point); queue_redraw()
	elif drawing and released:
		current.append(point); trails.append(current); drawing = false; _evaluate_stroke(); queue_redraw()


func _evaluate_stroke() -> void:
	if stroke_index >= guide.size() or current.size() < 2:
		if not trails.is_empty():
			trails.pop_back()
		current = PackedVector2Array()
		return
	var expected: Array = guide[stroke_index]
	var start: Vector2 = _to_canvas(expected.front())
	var ending: Vector2 = _to_canvas(expected.back())
	# Toleransi ramah untuk tangan anak: sedikit keluar dari garis tetap diterima,
	# tetapi coretan yang benar-benar menjauh dari bentuk huruf tetap tidak lolos.
	var tolerance := minf(size.x, size.y) * (0.20 if practice_stage == 2 else 0.25)
	var has_good_start := current[0].distance_to(start) <= tolerance
	var has_good_end := current[current.size() - 1].distance_to(ending) <= tolerance * 1.15
	var coverage := _path_coverage(expected, tolerance)
	if has_good_start and has_good_end and coverage >= 0.55:
		stroke_index += 1
		current = PackedVector2Array()
		if stroke_index >= guide.size():
			completed.emit()
	else:
		# Anak dapat mencoba lagi tanpa kehilangan goresan yang sudah benar.
		trails.pop_back()
	current = PackedVector2Array()


func _path_coverage(expected: Array, tolerance: float) -> float:
	var samples: Array[Vector2] = []
	for index in range(expected.size() - 1):
		var from: Vector2 = _to_canvas(expected[index])
		var to: Vector2 = _to_canvas(expected[index + 1])
		for step in range(7):
			samples.append(from.lerp(to, float(step) / 6.0))
	if samples.is_empty():
		return 0.0
	var covered := 0
	for sample in samples:
		for point in current:
			if point.distance_to(sample) <= tolerance:
				covered += 1
				break
	return float(covered) / float(samples.size())


func _draw() -> void:
	if asset_texture != null:
		_draw_asset_guide()
	else:
		_draw_default_guide()
	for trail in trails:
		if trail.size() > 1: draw_polyline(trail, Color("f58bb0"), 10.0, true)
	if current.size() > 1: draw_polyline(current, Color("f58bb0"), 10.0, true)


func _draw_default_guide() -> void:
	for stroke_number in range(guide.size()):
		var stroke_variant: Array = guide[stroke_number]
		var stroke: Array = stroke_variant
		var color := Color("9b8dcc", 0.25) if practice_stage == 3 else Color("9b8dcc")
		for index in range(stroke.size() - 1):
			if practice_stage == 3:
				draw_line(stroke[index] * size, stroke[index + 1] * size, color, 4.0)
			else:
				draw_dashed_line(stroke[index] * size, stroke[index + 1] * size, color, 5.0, 16.0)
		var start: Vector2 = stroke.front() * size
		draw_circle(start, 12.0, Color("f7d66d"))
		draw_circle(start, 5.0, Color("ffffff"))
		if practice_stage != 3:
			draw_string(get_theme_default_font(), start + Vector2(16, -12), str(stroke_number + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("554b45"))
			if stroke.size() > 1:
				_draw_direction_arrow(start, stroke[1] * size)
		if practice_stage == 1:
			_draw_preview_marker(stroke)


func _draw_direction_arrow(from: Vector2, to: Vector2) -> void:
	var direction := (to - from).normalized()
	var tip := from.lerp(to, 0.32)
	draw_line(tip - direction.rotated(0.55) * 12.0, tip, Color("89c7f5"), 4.0)
	draw_line(tip - direction.rotated(-0.55) * 12.0, tip, Color("89c7f5"), 4.0)


func _draw_preview_marker(stroke: Array) -> void:
	if stroke.size() < 2:
		return
	var segment_count := stroke.size() - 1
	var position_on_path := fposmod(preview_time * 0.65, 1.0) * segment_count
	var segment := mini(int(position_on_path), segment_count - 1)
	var progress := position_on_path - float(segment)
	var from: Vector2 = stroke[segment]
	var to: Vector2 = stroke[segment + 1]
	var point: Vector2 = from.lerp(to, progress) * size
	draw_circle(point, 10.0, Color("f58bb0"))


func _draw_asset_guide() -> void:
	# Nomor, panah, dan garis putus-putus sudah ada pada gambar aset.
	var tint := Color(1, 1, 1, 0.3) if practice_stage == 3 else Color.WHITE
	draw_texture_rect(asset_texture, _asset_rect(), false, tint)
	if practice_stage == 1:
		_draw_asset_preview()
	elif practice_stage == 2 and stroke_index < guide.size():
		var next_stroke: Array = guide[stroke_index]
		var start: Vector2 = _to_canvas(next_stroke.front())
		draw_circle(start, 12.0, Color("f7d66d"))
		draw_circle(start, 5.0, Color("ffffff"))


# Tahap 1: contoh menulis, satu goresan demi satu goresan sesuai nomor pada aset.
func _draw_asset_preview() -> void:
	if guide.is_empty():
		return
	var cycle := fposmod(preview_time, ASSET_SECONDS_PER_STROKE * guide.size())
	var active := mini(int(cycle / ASSET_SECONDS_PER_STROKE), guide.size() - 1)
	var active_progress := clampf((cycle - active * ASSET_SECONDS_PER_STROKE) / (ASSET_SECONDS_PER_STROKE * 0.75), 0.0, 1.0)
	for index in range(active + 1):
		var stroke: Array = guide[index]
		var points := _stroke_points_until(stroke, active_progress if index == active else 1.0)
		if points.size() > 1:
			draw_polyline(points, Color("f58bb0", 0.55), 9.0, true)
		if index == active and not points.is_empty():
			draw_circle(points[points.size() - 1], 11.0, Color("f58bb0"))


func _stroke_points_until(stroke: Array, amount: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	if stroke.size() < 2:
		return points
	var total := 0.0
	for index in range(stroke.size() - 1):
		total += _to_canvas(stroke[index]).distance_to(_to_canvas(stroke[index + 1]))
	var wanted := total * clampf(amount, 0.0, 1.0)
	var walked := 0.0
	points.append(_to_canvas(stroke[0]))
	for index in range(stroke.size() - 1):
		var from: Vector2 = _to_canvas(stroke[index])
		var to: Vector2 = _to_canvas(stroke[index + 1])
		var length := from.distance_to(to)
		if walked + length >= wanted:
			points.append(from.lerp(to, 0.0 if length <= 0.0 else (wanted - walked) / length))
			return points
		walked += length
		points.append(to)
	return points
