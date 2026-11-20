extends Control

const COLORS := [Color("89c7f5"), Color("f7d66d"), Color("c7b5ee"), Color("a9d9a2"), Color("f5b5b5")]
var content: VBoxContainer
var active_target := "A"
var activity_hint: Label
var attempts := 0
var selected_upper := ""
var pair_targets: Array[String] = []
var solved_pairs: Dictionary = {}
var pair_status: Label
var pair_upper_buttons: Dictionary = {}
var pair_lower_buttons: Dictionary = {}
var word_answer := ""
var word_built := ""
var word_label: Label
var word_tiles: HBoxContainer
var word_history: Array[Button] = []
var tracing_stage := 1
var sound_button: TextureButton
var sound_mute_slash: Line2D


func _ready() -> void:
	AudioManager.narration_requested.connect(_show_audio_fallback)
	build_screen()
	# Sapaan hanya diputar setelah tombol Mulai, bukan setiap kembali ke dashboard.
	if GameManager.current_screen == "activities" and GameManager.welcome_pending:
		GameManager.welcome_pending = false
		AudioManager.play_welcome()
	# Intro hanya diputar sekali saat Level 1 pertama kali dibuka dari dashboard.
	if GameManager.current_screen == "learning_selection" and GameManager.level1_intro_pending:
		GameManager.level1_intro_pending = false
		AudioManager.play_level1_intro()


func build_screen() -> void:
	for child in get_children():
		child.queue_free()
	if GameManager.current_screen == "activities":
		var learning_bg := TextureRect.new()
		learning_bg.texture = load("res://assets/backgrounds/learning_room.jpg")
		learning_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		learning_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		learning_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		learning_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(learning_bg)
	else:
		var desk_bg := TextureRect.new()
		desk_bg.texture = load("res://assets/backgrounds/activity_desk.jpg")
		desk_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		desk_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		desk_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		desk_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(desk_bg)
	var shell := VBoxContainer.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 40)
	shell.add_theme_constant_override("separation", 16)
	add_child(shell)
	var nav := HBoxContainer.new()
	nav.custom_minimum_size.y = 64
	nav.add_theme_constant_override("separation", 8)
	shell.add_child(nav)
	var back := make_art_button("res://assets/ui/navigation/back.png", func() -> void: go_back(), Vector2(138, 64), "Kembali")
	nav.add_child(back)
	var spacer := Control.new(); spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL; nav.add_child(spacer)
	# Tombol suara selalu berada di sebelah kiri pengaturan, dengan pengaturan di ujung kanan.
	nav.add_child(_make_sound_toggle_button())
	nav.add_child(make_art_button("res://assets/ui/navigation/settings.png", func() -> void: _show_sound_settings(), Vector2(64, 64), "Pengaturan suara"))
	content = VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	shell.add_child(content)
	match GameManager.current_screen:
		"activities": build_activities()
		"match_picture": build_picture_match()
		"listen_find": build_listen_find()
		"letter_pairs": build_letter_pairs()
		"word_builder": build_word_builder()
		"pencil_home": GameManager.open_screen("writing_selection")
		"learning_selection": build_letter_selection("Pilih Huruf", false)
		"letter_detail": build_detail()
		"matching": build_matching()
		"hunt": build_hunt()
		"writing_selection": build_letter_selection("Pilih Huruf untuk Ditulis", true)
		"case_selection": build_case_selection()
		"tracing": build_tracing()
		"collection": build_collection()
		_: build_letter_selection("Pilih Huruf", false)


func build_activities() -> void:
	var title_slot := Control.new()
	title_slot.custom_minimum_size = Vector2(720, 150)
	title_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(title_slot)
	var title := TextureRect.new()
	title.texture = load("res://assets/ui/learning_room_title.png")
	title.custom_minimum_size = Vector2(720, 160)
	title.position = Vector2(0, -18)
	title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_slot.add_child(title)
	var activity_area := VBoxContainer.new()
	activity_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	activity_area.add_theme_constant_override("separation", 2)
	activity_area.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(activity_area)
	var activities := [
		{"asset":"res://assets/ui/pastel/level_1_pengenalan_huruf.png", "screen":"learning_selection"},
		{"asset":"res://assets/ui/pastel/level_2_audio.png", "screen":"listen_find"},
		{"asset":"res://assets/ui/pastel/level_3_kapital.png", "screen":"letter_pairs"},
		{"asset":"res://assets/ui/pastel/level_4_rumah_pensil.png", "screen":"writing_selection"}
	]
	var first_row := HBoxContainer.new()
	first_row.alignment = BoxContainer.ALIGNMENT_CENTER
	first_row.add_theme_constant_override("separation", 18)
	activity_area.add_child(first_row)
	var second_row := HBoxContainer.new()
	second_row.alignment = BoxContainer.ALIGNMENT_CENTER
	second_row.add_theme_constant_override("separation", 18)
	activity_area.add_child(second_row)
	var level_one_started := ProgressManager.has_started_level_one()
	for index in activities.size():
		var entry_variant = activities[index]
		var entry: Dictionary = entry_variant
		var screen: String = entry.screen
		var is_locked := index > 0 and not level_one_started
		var activity_button := make_activity_button(entry.asset, func() -> void:
			if is_locked:
				_show_level_one_required()
			else:
				if screen == "learning_selection":
					GameManager.level1_intro_pending = true
				GameManager.open_screen(screen)
		)
		if is_locked:
			activity_button.modulate = Color(0.52, 0.52, 0.52, 1.0)
			activity_button.tooltip_text = "Mainkan Level 1 dulu untuk membuka level ini"
		if index < 2:
			first_row.add_child(activity_button)
		else:
			second_row.add_child(activity_button)


func _show_level_one_required() -> void:
	show_feedback("Level ini masih terkunci. Yuk, mainkan Level 1 dulu!", Callable())


func make_activity_button(texture_path: String, action: Callable) -> TextureButton:
	var button := TextureButton.new()
	button.custom_minimum_size = Vector2(290, 192)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var art := TextureRect.new()
	art.texture = load(texture_path)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(art)
	button.pressed.connect(action)
	button.mouse_entered.connect(func() -> void: animate_texture_button(button, 1.05))
	button.mouse_exited.connect(func() -> void: animate_texture_button(button, 1.0))
	return button


func make_art_button(texture_path: String, action: Callable, button_size: Vector2, tooltip: String) -> TextureButton:
	var button := TextureButton.new()
	button.custom_minimum_size = button_size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = load(texture_path)
	button.tooltip_text = tooltip
	button.pressed.connect(action)
	button.mouse_entered.connect(func() -> void: animate_texture_button(button, 1.04))
	button.mouse_exited.connect(func() -> void: animate_texture_button(button, 1.0))
	return button


func _make_sound_toggle_button() -> TextureButton:
	sound_button = TextureButton.new()
	sound_button.custom_minimum_size = Vector2(132, 64)
	sound_button.ignore_texture_size = true
	sound_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	sound_button.texture_normal = load("res://assets/ui/navigation/sound.png")
	sound_button.tooltip_text = "Matikan suara" if AudioManager.sound_enabled else "Nyalakan suara"
	sound_button.pressed.connect(_toggle_sound)
	sound_button.mouse_entered.connect(func() -> void: animate_texture_button(sound_button, 1.04))
	sound_button.mouse_exited.connect(func() -> void: animate_texture_button(sound_button, 1.0))

	# Garis merah tampil hanya saat suara dimatikan; dibuat sebagai overlay agar aset asli tetap utuh.
	sound_mute_slash = Line2D.new()
	sound_mute_slash.points = PackedVector2Array([Vector2(28, 57), Vector2(105, 7)])
	sound_mute_slash.width = 7.0
	sound_mute_slash.default_color = Color("e64545")
	sound_mute_slash.antialiased = true
	sound_mute_slash.visible = not AudioManager.sound_enabled
	sound_button.add_child(sound_mute_slash)
	return sound_button


func _toggle_sound() -> void:
	var is_enabled := AudioManager.toggle_sound()
	if is_instance_valid(sound_mute_slash):
		sound_mute_slash.visible = not is_enabled
	if is_instance_valid(sound_button):
		sound_button.tooltip_text = "Matikan suara" if is_enabled else "Nyalakan suara"


func cropped_texture(texture_path: String, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(texture_path)
	atlas.region = region
	return atlas


func animate_texture_button(button: TextureButton, target_scale: float) -> void:
	button.pivot_offset = button.size * 0.5
	create_tween().tween_property(button, "scale", Vector2.ONE * target_scale, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _show_sound_settings() -> void:
	var overlay := Control.new()
	overlay.name = "SoundSettings"
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
	var music_slider := _make_volume_slider(AudioManager.music_volume_db, -40.0, 0.0, Color("f4c75d"))
	music_slider.position = Vector2(255, 225)
	music_slider.size = Vector2(380, 28)
	music_slider.value_changed.connect(func(value: float) -> void: AudioManager.set_music_volume(value))
	panel.add_child(music_slider)
	var sfx_slider := _make_volume_slider(AudioManager.sfx_volume_db, -40.0, 0.0, Color("9dcff7"))
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


func _make_volume_slider(value: float, minimum: float, maximum: float, accent: Color) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
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
	# The source art deliberately leaves these two rows blank.  These StyleBoxes
	# provide the visible, touch-friendly volume bar on top of those spaces.
	track.content_margin_top = 8
	track.content_margin_bottom = 8
	filled.content_margin_top = 8
	filled.content_margin_bottom = 8
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", filled)
	slider.add_theme_stylebox_override("grabber_area_highlight", filled)
	return slider


func build_picture_match() -> void:
	active_target = AlphabetData.letters()[randi() % 26]
	attempts = 0
	make_title("Cocokkan Gambar", "Pilih gambar yang dimulai dengan huruf %s · %s" % [active_target, GameManager.difficulty_label()])
	var big := Label.new(); big.text = active_target; big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; big.add_theme_font_size_override("font_size", 110); big.add_theme_color_override("font_color", Color("8c70c7")); content.add_child(big)
	activity_hint = make_hint("Lumi: Cari bunyi awal %s." % active_target)
	AudioManager.play_instruction("match_picture", "Halo! Yuk, kita cocokkan huruf dengan gambarnya! Coba cari gambar yang namanya diawali huruf %s!" % active_target)
	var choices: Array[String] = make_choices(active_target, false, GameManager.choice_count())
	var row := HBoxContainer.new(); row.alignment = BoxContainer.ALIGNMENT_CENTER; row.size_flags_vertical = Control.SIZE_EXPAND_FILL; content.add_child(row)
	for option in choices:
		var info := AlphabetData.info(option)
		var choice := option
		var button := make_button("%s\n%s" % [info.emoji, info.word], func() -> void: answer_picture(choice), COLORS[randi() % COLORS.size()])
		button.custom_minimum_size = Vector2(210, 135); button.add_theme_font_size_override("font_size", 25); row.add_child(button)


func answer_picture(choice: String) -> void:
	AudioManager.play_word(AlphabetData.info(choice).word)
	if choice == active_target:
		ProgressManager.mark_learned(choice); ProgressManager.mark_activity_complete("match_picture"); AudioManager.play_feedback_correct("Hebat! Ini gambar %s. %s dimulai dengan huruf %s!" % [AlphabetData.info(choice).word, AlphabetData.info(choice).word, active_target]); show_feedback("Hebat! %s untuk %s." % [active_target, AlphabetData.info(choice).word], func() -> void: GameManager.open_screen("match_picture"))
	else:
		attempts += 1
		activity_hint.text = "Lumi: Belum itu. Ucapkan pelan-pelan: %s... %s." % [active_target, active_target]
		AudioManager.play_feedback_retry("Hmm, belum tepat. Yuk, coba cari gambar yang lain!")
		show_feedback("Tidak apa-apa. Kita coba lagi pada soal yang sama, ya!", Callable())


func build_listen_find() -> void:
	if GameManager.level2_round_letters.is_empty():
		var shuffled_letters: Array[String] = []
		for letter in AlphabetData.letters():
			shuffled_letters.append(letter)
		shuffled_letters.shuffle()
		GameManager.level2_round_letters = shuffled_letters.slice(0, 5)
	active_target = GameManager.level2_round_letters[GameManager.level2_progress]
	attempts = 0
	make_title("Level 2 — Audio", "Progress %s/5 · Dengarkan lalu pilih huruf yang benar" % (GameManager.level2_progress + 1))
	var replay := make_art_button("res://assets/ui/activity_listen_button.png", func() -> void: AudioManager.play_letter(active_target), Vector2(330, 128), "Putar audio huruf %s" % active_target)
	replay.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(replay)
	activity_hint = make_hint("Dengarkan baik-baik, lalu tekan hurufnya.")
	# Huruf baru diperdengarkan saat anak menekan tombol Putar Audio.
	var row := HBoxContainer.new(); row.alignment = BoxContainer.ALIGNMENT_CENTER; row.size_flags_vertical = Control.SIZE_SHRINK_CENTER; row.add_theme_constant_override("separation", 16); content.add_child(row)
	for option in make_choices(active_target, false, GameManager.choice_count()):
		var choice := option
		row.add_child(make_alphabet_tile(choice, func() -> void: answer_listen(choice), Vector2(150, 150)))
	# Sedikit ruang di bawah membuat pilihan Level Audio naik dan lebih nyaman di tengah layar.
	var bottom_offset := Control.new()
	bottom_offset.custom_minimum_size = Vector2(0, 36)
	content.add_child(bottom_offset)


func answer_listen(choice: String) -> void:
	if choice == active_target:
		ProgressManager.mark_learned(choice)
		GameManager.level2_progress += 1
		AudioManager.play_feedback_correct("Benar! Ini huruf %s!" % choice)
		if GameManager.level2_progress >= GameManager.level2_round_letters.size():
			ProgressManager.mark_activity_complete("listen_find")
			GameManager.level2_progress = 0
			GameManager.level2_round_letters.clear()
			show_feedback("Hebat! Lima huruf acak sudah berhasil dikenali.", func() -> void: GameManager.open_screen("activities"))
		else:
			show_feedback("Benar! Itu huruf %s." % choice, func() -> void: GameManager.open_screen("listen_find"))
	else:
		attempts += 1
		activity_hint.text = "Lumi: Belum itu. Tekan tombol Ulangi Suara, lalu coba lagi."
		AudioManager.play_feedback_retry("Belum tepat. Dengarkan sekali lagi, yuk!")
		show_feedback("Tidak apa-apa. Soalnya tetap sama supaya kamu bisa mencoba lagi.", Callable())


func build_letter_pairs() -> void:
	var pool: Array[String] = []
	for letter in AlphabetData.letters():
		if not GameManager.level3_completed.has(letter):
			pool.append(letter)
	pool.shuffle()
	pair_targets.clear()
	for index in mini(GameManager.choice_count(), pool.size()):
		pair_targets.append(pool[index])
	solved_pairs.clear(); selected_upper = ""; pair_upper_buttons.clear(); pair_lower_buttons.clear()
	make_title("Level 3 — Pilih Kapital dan Tidak", "Progress %s/26 · Pasangkan huruf besar dengan huruf kecil" % GameManager.level3_completed.size())
	pair_status = make_hint("Lumi: Pilih satu huruf kapital dulu.")
	AudioManager.play_instruction("letter_pairs", "Yuk, pasangkan huruf besar dengan huruf kecil yang sama!")
	var upper_row := HBoxContainer.new(); upper_row.alignment = BoxContainer.ALIGNMENT_CENTER; content.add_child(upper_row)
	for upper in pair_targets:
		var selected: String = upper
		var button := make_case_tile(selected, true, func() -> void: choose_upper(selected), Vector2(140, 130)); upper_row.add_child(button)
		pair_upper_buttons[selected] = button
	var lower_row := HBoxContainer.new(); lower_row.alignment = BoxContainer.ALIGNMENT_CENTER; lower_row.size_flags_vertical = Control.SIZE_EXPAND_FILL; content.add_child(lower_row)
	var lowers: Array[String] = []
	for letter in pair_targets: lowers.append(letter.to_lower())
	lowers.shuffle()
	for lower in lowers:
		var selected: String = lower
		var button := make_case_tile(selected, false, func() -> void: choose_lower(selected), Vector2(140, 130)); lower_row.add_child(button)
		pair_lower_buttons[selected] = button


func choose_upper(letter: String) -> void:
	if solved_pairs.has(letter):
		return
	selected_upper = letter
	pair_status.text = "Lumi: Sekarang cari huruf kecil %s." % letter.to_lower()
	for upper in pair_upper_buttons:
		pair_upper_buttons[upper].modulate = Color.WHITE if upper == letter else Color(1, 1, 1, 0.58)


func choose_lower(letter: String) -> void:
	if selected_upper.is_empty():
		pair_status.text = "Lumi: Pilih huruf kapital dulu, ya."
		show_feedback("Pilih huruf kapital dulu, ya.", Callable()); return
	if selected_upper.to_lower() == letter:
		var matched_upper := selected_upper
		solved_pairs[matched_upper] = true; ProgressManager.mark_paired(matched_upper)
		pair_upper_buttons[matched_upper].disabled = true; pair_upper_buttons[matched_upper].modulate = Color(0.55, 1, 0.65, 1)
		pair_lower_buttons[letter].disabled = true; pair_lower_buttons[letter].modulate = Color(0.55, 1, 0.65, 1)
		if solved_pairs.size() == pair_targets.size():
			for completed_letter in pair_targets:
				GameManager.level3_completed[completed_letter] = true
			if GameManager.level3_completed.size() >= 26:
				ProgressManager.mark_activity_complete("letter_pairs")
				GameManager.level3_completed.clear()
				AudioManager.play_feedback_correct("Hebat! Semua pasangan huruf sudah benar!")
				show_feedback("Level 3 selesai! Kamu berhasil memasangkan 26 huruf.", func() -> void: GameManager.open_screen("activities"))
			else:
				AudioManager.play_feedback_correct("Bagus! Kita lanjut ke pasangan berikutnya.")
				show_feedback("Bagus! %s dari 26 huruf sudah dipasangkan." % GameManager.level3_completed.size(), func() -> void: GameManager.open_screen("letter_pairs"))
		else:
			selected_upper = ""; pair_status.text = "Hebat! Pilih huruf kapital berikutnya."
			for upper in pair_upper_buttons:
				if not solved_pairs.has(upper): pair_upper_buttons[upper].modulate = Color.WHITE
	else:
		pair_status.text = "Lumi: Belum cocok. Coba huruf kecil lain untuk %s." % selected_upper
		AudioManager.play_feedback_retry("Belum cocok, coba cari pasangannya lagi!")
		show_feedback("Hampir! Kita coba lagi tanpa mengulang pasangan yang sudah benar.", Callable())


func build_word_builder() -> void:
	var practice := AlphabetData.word_practice(GameManager.difficulty); var picked: Dictionary = practice[randi() % practice.size()]
	word_answer = picked.word; word_built = ""; word_history.clear()
	make_title("Susun Kata", "Susun huruf sesuai gambar · %s" % GameManager.difficulty_label())
	var emoji := Label.new(); emoji.text = picked.emoji; emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; emoji.add_theme_font_size_override("font_size", 100); content.add_child(emoji)
	word_label = Label.new(); word_label.text = "_ ".repeat(word_answer.length()); word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; word_label.add_theme_font_size_override("font_size", 40); word_label.add_theme_color_override("font_color", Color("554b45")); content.add_child(word_label)
	AudioManager.play_instruction("word_builder", "Ayo susun huruf menjadi sebuah kata! Perhatikan gambar ini. Ini adalah %s. Sekarang, ayo susun hurufnya!" % word_answer.capitalize())
	word_tiles = HBoxContainer.new(); word_tiles.alignment = BoxContainer.ALIGNMENT_CENTER; word_tiles.size_flags_vertical = Control.SIZE_EXPAND_FILL; content.add_child(word_tiles)
	var chars: Array[String] = []
	for character in word_answer: chars.append(character)
	chars.shuffle()
	for character in chars:
		var tile := character
		var button := make_button(tile, Callable(), Color("f7d66d")); button.custom_minimum_size = Vector2(90, 80); button.add_theme_font_size_override("font_size", 34); word_tiles.add_child(button)
		button.pressed.connect(func() -> void: add_word_letter(tile, button))
	var word_actions := HBoxContainer.new(); word_actions.alignment = BoxContainer.ALIGNMENT_CENTER; content.add_child(word_actions)
	word_actions.add_child(make_button("↩ Hapus Terakhir", func() -> void: remove_last_word_letter(), Color("c7b5ee")))
	word_actions.add_child(make_button("Ulangi Kata", func() -> void: reset_word(), Color("f5b5b5")))


func add_word_letter(letter: String, source: Button) -> void:
	if word_built.length() >= word_answer.length(): return
	AudioManager.play_letter(letter)
	word_built += letter; source.disabled = true; word_history.append(source); update_word_label()
	if word_built == word_answer:
		ProgressManager.mark_word(word_answer); ProgressManager.mark_activity_complete("word_builder"); AudioManager.play_feedback_correct("Hebat! Kamu berhasil menyusun kata %s!" % word_answer); show_feedback("Hebat! Kamu menyusun kata %s." % word_answer, func() -> void: GameManager.open_screen("word_builder"))
	elif word_built.length() == word_answer.length():
		AudioManager.play_feedback_retry("Hmm, masih belum tepat. Yuk, coba susun lagi!")
		show_feedback("Susunannya belum pas. Kamu boleh hapus huruf terakhir atau ulangi kata.", Callable())


func reset_word() -> void:
	word_built = ""
	for button in word_history: button.disabled = false
	word_history.clear(); update_word_label()


func remove_last_word_letter() -> void:
	if word_history.is_empty():
		return
	var removed: Button = word_history.pop_back(); removed.disabled = false
	word_built = word_built.left(-1); update_word_label()


func update_word_label() -> void:
	var spaces := "_ ".repeat(word_answer.length() - word_built.length())
	word_label.text = " ".join(word_built.split("", false)) + (" " if not word_built.is_empty() and not spaces.is_empty() else "") + spaces.strip_edges()


func make_title(text: String, subtitle := "") -> void:
	var title := Label.new()
	title.text = text; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36); title.add_theme_color_override("font_color", Color("554b45"))
	content.add_child(title)
	if not subtitle.is_empty():
		var label := Label.new(); label.text = subtitle; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 19); label.add_theme_color_override("font_color", Color("6b6070")); content.add_child(label)


func make_button(text: String, action: Callable, color: Color) -> Button:
	var button := Button.new()
	button.text = text; button.custom_minimum_size = Vector2(0, 52)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", style(color))
	button.add_theme_stylebox_override("hover", style(color.lightened(0.10)))
	button.add_theme_stylebox_override("pressed", style(color.darkened(0.10)))
	if not action.is_null():
		button.pressed.connect(action)
	return button


func style(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new(); box.bg_color = color
	box.corner_radius_top_left = 18; box.corner_radius_top_right = 18; box.corner_radius_bottom_left = 18; box.corner_radius_bottom_right = 18
	box.shadow_color = Color(0.2, 0.15, 0.25, 0.18); box.shadow_size = 4; box.shadow_offset = Vector2(0, 3)
	return box


func build_letter_selection(title: String, writing: bool) -> void:
	make_title(title, "Tekan huruf yang ingin kamu pilih")
	# Semua 26 huruf muat dalam empat baris pada 1280×720, jadi gunakan area tengah
	# daripada ScrollContainer agar susunannya tidak bergeser ke kiri.
	var centered := CenterContainer.new()
	centered.custom_minimum_size = Vector2(0, 410)
	centered.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centered.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(centered)
	var grid := GridContainer.new()
	grid.columns = 7
	grid.custom_minimum_size = Vector2(740, 410)
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	centered.add_child(grid)
	for letter in AlphabetData.letters():
		var chosen := letter
		grid.add_child(make_alphabet_tile(chosen, func() -> void: open_letter(chosen, writing), Vector2(92, 92)))
	var bottom_offset := Control.new()
	bottom_offset.custom_minimum_size = Vector2(0, 30)
	content.add_child(bottom_offset)


func make_alphabet_tile(letter: String, action: Callable, tile_size := Vector2(108, 125)) -> TextureButton:
	var button := TextureButton.new()
	button.custom_minimum_size = tile_size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = load("res://assets/ui/alphabet/plain/%s.png" % letter)
	button.tooltip_text = "Huruf %s" % letter
	button.pressed.connect(action)
	# Suara huruf selalu diputar setelah aksinya, sehingga suara feedback dari
	# level mana pun tidak langsung memotong rekaman huruf yang baru disentuh.
	button.pressed.connect(func() -> void: AudioManager.play_letter(letter))
	button.mouse_entered.connect(func() -> void: animate_texture_button(button, 1.04))
	button.mouse_exited.connect(func() -> void: animate_texture_button(button, 1.0))
	return button


func make_case_tile(letter: String, uppercase: bool, action: Callable, tile_size := Vector2(140, 130)) -> TextureButton:
	var button := TextureButton.new()
	button.custom_minimum_size = tile_size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	var folder := "uppercase" if uppercase else "lowercase"
	var filename := letter if uppercase else letter.to_lower()
	button.texture_normal = load("res://assets/ui/alphabet/%s/%s.png" % [folder, filename])
	button.tooltip_text = "Huruf %s" % letter
	button.pressed.connect(action)
	# Berlaku juga untuk kartu kapital dan kecil di seluruh aktivitas.
	button.pressed.connect(func() -> void: AudioManager.play_letter(letter))
	button.mouse_entered.connect(func() -> void: animate_texture_button(button, 1.04))
	button.mouse_exited.connect(func() -> void: animate_texture_button(button, 1.0))
	return button


func open_letter(letter: String, writing: bool) -> void:
	if not writing:
		ProgressManager.mark_learned(letter)
	GameManager.open_screen("case_selection" if writing else "letter_detail", letter)


func open_letter_detail_with_audio(letter: String) -> void:
	AudioManager.play_letter(letter)
	GameManager.open_screen("letter_detail", letter)


func build_detail() -> void:
	var info := AlphabetData.info(GameManager.selected_letter)
	make_title("Huruf %s/%s" % [info.upper, info.lower], "Tekan bagian huruf untuk mendengarkan bunyinya")
	var card := Control.new()
	card.custom_minimum_size = Vector2(330, 385)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(card)
	var art := TextureRect.new()
	art.texture = load("res://assets/ui/alphabet/illustrated/%s.png" % info.upper)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(art)
	var letter_audio := Button.new()
	letter_audio.flat = true
	letter_audio.tooltip_text = "Dengarkan huruf %s" % info.upper
	# Seluruh kartu huruf dan gambarnya dapat disentuh, bukan hanya area huruf.
	letter_audio.position = Vector2.ZERO
	letter_audio.size = card.custom_minimum_size
	letter_audio.pressed.connect(func() -> void: AudioManager.play_letter(info.upper))
	card.add_child(letter_audio)
	var actions := HBoxContainer.new(); actions.alignment = BoxContainer.ALIGNMENT_CENTER; content.add_child(actions)
	var letters := AlphabetData.letters()
	var current_index := letters.find(info.upper)
	actions.add_theme_constant_override("separation", 18)
	var previous_button := make_art_button("res://assets/ui/navigation/sebelumnya.png", func() -> void: open_letter_detail_with_audio(letters[maxi(0, current_index - 1)]), Vector2(205, 82), "Huruf sebelumnya")
	var next_button := make_art_button("res://assets/ui/navigation/selanjutnya.png", func() -> void: open_letter_detail_with_audio(letters[mini(25, current_index + 1)]), Vector2(205, 82), "Huruf selanjutnya")
	previous_button.disabled = current_index == 0
	next_button.disabled = current_index == 25
	actions.add_child(previous_button)
	actions.add_child(next_button)


func build_matching() -> void:
	active_target = GameManager.selected_letter
	make_title("Pasangkan Huruf", "Temukan huruf kecil yang cocok dengan %s" % active_target)
	var target := Label.new(); target.text = active_target; target.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; target.add_theme_font_size_override("font_size", 130); target.add_theme_color_override("font_color", Color("8c70c7")); content.add_child(target)
	var row := HBoxContainer.new(); row.alignment = BoxContainer.ALIGNMENT_CENTER; content.add_child(row)
	for option in make_choices(active_target, true):
		var choice := option
		row.add_child(make_button(choice, func() -> void: answer_matching(choice), COLORS[randi() % COLORS.size()]))


func answer_matching(choice: String) -> void:
	if choice == active_target.to_lower():
		ProgressManager.mark_learned(active_target); AudioManager.play_success(); show_feedback("Hebat! %s dan %s adalah pasangan!" % [active_target, choice], func() -> void: GameManager.open_screen("letter_detail", active_target))
	else:
		show_feedback("Ayo coba lagi! Cari huruf kecil %s pada pilihan yang sama." % active_target.to_lower(), Callable())


func build_hunt() -> void:
	active_target = AlphabetData.letters()[randi() % 26]
	make_title("Berburu Huruf", "Ayo cari huruf %s!" % active_target)
	var grid := GridContainer.new(); grid.columns = 3; grid.size_flags_vertical = Control.SIZE_EXPAND_FILL; grid.add_theme_constant_override("h_separation", 18); grid.add_theme_constant_override("v_separation", 18); content.add_child(grid)
	for option in make_choices(active_target, false):
		var choice := option
		var button := make_button(choice, func() -> void: answer_hunt(choice), COLORS[randi() % COLORS.size()])
		button.custom_minimum_size = Vector2(0, 120); button.add_theme_font_size_override("font_size", 54); grid.add_child(button)


func answer_hunt(choice: String) -> void:
	if choice == active_target:
		ProgressManager.mark_learned(active_target); AudioManager.play_success(); show_feedback("Kamu berhasil menemukan %s!" % active_target, func() -> void: GameManager.open_screen("hunt"))
	else:
		show_feedback("Belum itu. Yuk cari huruf %s lagi pada pilihan yang sama!" % active_target, Callable())


func make_choices(target: String, lower := false, count := 3) -> Array[String]:
	var result: Array[String] = [target.to_lower() if lower else target]
	var letters: Array[String] = []
	for available_letter in AlphabetData.letters():
		letters.append(available_letter)
	letters.shuffle()
	for letter in letters:
		var option := letter.to_lower() if lower else letter
		if option not in result:
			result.append(option)
		if result.size() == count: break
	result.shuffle(); return result


func make_hint(text: String) -> Label:
	var hint := Label.new()
	hint.text = text; hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18); hint.add_theme_color_override("font_color", Color("6b6070"))
	content.add_child(hint)
	return hint


func _show_audio_fallback(text: String) -> void:
	# Audio file belum tersedia: tampilkan narasi yang sama agar instruksi tetap bisa diikuti.
	if is_instance_valid(activity_hint):
		activity_hint.text = "🔊 Lumi: %s" % text


func difficulty_description() -> String:
	return {
		"easy": "3 pilihan dan petunjuk lebih banyak",
		"medium": "4 pilihan untuk latihan lebih jauh",
		"challenge": "5 pilihan dan kata lebih panjang"
	}.get(GameManager.difficulty, "3 pilihan dan petunjuk lebih banyak")


func build_case_selection() -> void:
	tracing_stage = 1
	make_title("Pilih Bentuk Huruf", "Mau menulis huruf %s yang mana?" % GameManager.selected_letter)
	var row := HBoxContainer.new(); row.alignment = BoxContainer.ALIGNMENT_CENTER; row.size_flags_vertical = Control.SIZE_EXPAND_FILL; content.add_child(row)
	row.add_child(make_case_tile(GameManager.selected_letter, true, func() -> void: GameManager.open_screen("tracing", GameManager.selected_letter, "upper"), Vector2(250, 235)))
	row.add_child(make_case_tile(GameManager.selected_letter, false, func() -> void: GameManager.open_screen("tracing", GameManager.selected_letter, "lower"), Vector2(250, 235)))


func build_tracing() -> void:
	var shown := GameManager.selected_letter if GameManager.selected_case == "upper" else GameManager.selected_letter.to_lower()
	var stage_text: String = ["Lihat contoh goresannya", "Ikuti garis putus-putusnya", "Coba tulis sendiri!"][tracing_stage - 1]
	make_title("Rumah Pensil: %s" % shown, "Tahap %s dari 3 — %s" % [tracing_stage, stage_text])
	var canvas := TracingCanvas.new(); canvas.custom_minimum_size = Vector2(620, 390); canvas.size_flags_horizontal = Control.SIZE_SHRINK_CENTER; canvas.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	canvas.modulate.a = 0.0
	canvas.scale = Vector2(0.96, 0.96)
	canvas.set_letter(GameManager.selected_letter, GameManager.selected_case, tracing_stage); canvas.completed.connect(func() -> void: advance_tracing())
	if tracing_stage == 1: canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(canvas)
	call_deferred("_animate_tracing_canvas", canvas)
	if tracing_stage == 1:
		# Tombol berada di dalam area tracing agar tidak terdorong ke bawah layar oleh VBox.
		var start_button := make_art_button("res://assets/ui/tracing/mulai_ikuti.png", func() -> void: start_follow_stage(), Vector2(250, 100), "Mulai ikuti garis")
		start_button.position = Vector2(185, 330)
		start_button.modulate.a = 0.0
		start_button.scale = Vector2(0.9, 0.9)
		canvas.add_child(start_button)
		call_deferred("_animate_tracing_button", start_button)


func _animate_tracing_canvas(canvas: Control) -> void:
	canvas.pivot_offset = canvas.size * 0.5
	var entry := create_tween().set_parallel(true)
	entry.tween_property(canvas, "modulate:a", 1.0, 0.28)
	entry.tween_property(canvas, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _animate_tracing_button(button: Control) -> void:
	button.pivot_offset = button.size * 0.5
	var entry := create_tween().set_parallel(true)
	entry.tween_property(button, "modulate:a", 1.0, 0.2).set_delay(0.18)
	entry.tween_property(button, "scale", Vector2.ONE, 0.26).set_delay(0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func start_follow_stage() -> void:
	tracing_stage = 2
	build_screen()


func advance_tracing() -> void:
	if tracing_stage == 2:
		tracing_stage = 3
		build_screen()
	else:
		complete_tracing()


func complete_tracing() -> void:
	ProgressManager.mark_written(GameManager.selected_letter); ProgressManager.mark_activity_complete("pencil_home"); AudioManager.play_success(); tracing_stage = 1; show_feedback("Wah, bagus sekali! Kamu menulis %s." % GameManager.selected_letter, func() -> void: GameManager.open_screen("writing_selection"))


func build_collection() -> void:
	make_title("Buku Koleksi Alfabet", "Kartu abu-abu belum dimainkan · kartu hijau sudah dimainkan")
	var centered := CenterContainer.new()
	centered.custom_minimum_size = Vector2(0, 430)
	centered.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centered.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(centered)
	var grid := GridContainer.new()
	grid.columns = 7
	grid.custom_minimum_size = Vector2(826, 430)
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	centered.add_child(grid)
	for letter in AlphabetData.letters():
		var chosen := letter
		var is_played := ProgressManager.is_learned(chosen)
		var card := TextureButton.new()
		card.custom_minimum_size = Vector2(104, 96)
		card.ignore_texture_size = true
		card.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		card.texture_normal = load("res://assets/ui/alphabet/illustrated/%s.png" % chosen)
		card.tooltip_text = "Huruf %s" % chosen if is_played else "Mainkan huruf %s di Level 1 dulu" % chosen
		card.disabled = not is_played
		card.modulate = Color(0.68, 1.0, 0.68, 1.0) if is_played else Color(0.5, 0.5, 0.5, 1.0)
		if is_played:
			card.pressed.connect(func() -> void: GameManager.open_screen("letter_detail", chosen))
			card.pressed.connect(func() -> void: AudioManager.play_letter(chosen))
			card.mouse_entered.connect(func() -> void: animate_texture_button(card, 1.04))
			card.mouse_exited.connect(func() -> void: animate_texture_button(card, 1.0))
		grid.add_child(card)


func show_feedback(message: String, next: Callable) -> void:
	var popup := Control.new(); popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE, 0); popup.position = Vector2(-350, -205); popup.size = Vector2(700, 410)
	add_child(popup)
	var panel_art := TextureRect.new()
	panel_art.texture = load("res://assets/ui/dialogs/feedback_panel.png")
	panel_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.add_child(panel_art)
	var label := Label.new()
	label.text = message
	# Area pesan dibuat cukup lebar supaya kalimat feedback Level 3 tidak pecah
	# menjadi dua baris dan menimpa dekorasi bintang di tengah panel.
	label.position = Vector2(70, 88)
	label.size = Vector2(560, 70)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color("5b3525"))
	popup.add_child(label)
	# Tombol visual sudah ada pada ilustrasi panel; area transparan ini menjadikannya interaktif.
	var continue_button := Button.new()
	continue_button.flat = true
	continue_button.tooltip_text = "Lanjut"
	continue_button.position = Vector2(245, 300)
	continue_button.size = Vector2(210, 82)
	continue_button.pressed.connect(func() -> void:
		popup.queue_free()
		if not next.is_null(): next.call()
	)
	popup.add_child(continue_button)


func go_back() -> void:
	var previous := {"activities":"main_menu", "match_picture":"activities", "listen_find":"activities", "letter_pairs":"activities", "word_builder":"activities", "letter_detail":"learning_selection", "matching":"letter_detail", "hunt":"activities", "writing_selection":"activities", "case_selection":"writing_selection", "tracing":"case_selection", "collection":"main_menu"}
	var destination: String = previous.get(GameManager.current_screen, "activities")
	if destination == "main_menu": GameManager.go_to(destination)
	elif destination == "activities": GameManager.open_screen(destination)
	else: GameManager.open_screen(destination, GameManager.selected_letter)
