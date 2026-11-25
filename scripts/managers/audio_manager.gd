extends Node

signal narration_requested(text: String)

const MENU_MUSIC_PATH := "res://audio/music/menu_theme.mp3"
const MENU_INTRO_PATH := "res://audio/music/Literaku.mp3"
const BUTTON_SOUND_PATH := "res://audio/sfx/button_click.mp3"
const MENU_VOLUME_DB := -22.0
const BUTTON_VOLUME_DB := -17.0
const VOICE_VOLUME_DB := -7.0

# Pelafalan untuk kata yang ejaannya tidak biasa (dipakai saat suara dibacakan browser).
const SPOKEN_WORDS := {"QUEEN": "Kuin", "XILOFON": "Silofon", "DINOSAURUS": "Dinosaurus", "WAYANG": "Wayang"}

# Suara sapaan (file ada di res://audio/voice/ui/)
const WELCOME_ID := "ui/welcome"
const WELCOME_TEXT := "Selamat datang di ruang belajar Literaku!"
const WELCOME_DELAY := 0.3  # jeda (detik) setelah tombol Mulai ditekan
const LEVEL1_INTRO_ID := "ui/level1_intro"
const LEVEL1_INTRO_TEXT := "Ayo belajar huruf-huruf bersama Literaku!"
const LEVEL1_INTRO_DELAY := 0.2  # jeda (detik) setelah halaman utama Level 1 muncul

var sound_enabled := true
var music_volume_db := MENU_VOLUME_DB
var sfx_volume_db := BUTTON_VOLUME_DB
var voice_volume_db := VOICE_VOLUME_DB
var menu_music: AudioStreamPlayer
var menu_intro: AudioStreamPlayer
var button_sfx: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var last_audio_id := ""
var last_audio_text := ""
var queued_audio: Array[Dictionary] = []
var menu_intro_played := false
var _delayed_voice_token := 0


func _ready() -> void:
	menu_music = _make_player("MenuMusic", music_volume_db)
	menu_intro = _make_player("MenuIntro", music_volume_db)
	menu_intro.finished.connect(_play_menu_music_after_intro)
	button_sfx = _make_player("ButtonSfx", BUTTON_VOLUME_DB)
	voice_player = _make_player("VoiceNarration", voice_volume_db)
	voice_player.finished.connect(_play_next_queued_audio)
	get_tree().node_added.connect(_on_node_added)
	call_deferred("_register_existing_buttons")
	_tts_setup()


func _make_player(player_name: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.volume_db = volume
	add_child(player)
	return player


func toggle_sound() -> bool:
	sound_enabled = not sound_enabled
	if not sound_enabled:
		_tts_stop()
	for player in [menu_music, menu_intro, button_sfx, voice_player]:
		if player:
			player.stream_paused = not sound_enabled
	return sound_enabled


func set_music_volume(value_db: float) -> void:
	music_volume_db = clampf(value_db, -40.0, 0.0)
	menu_music.volume_db = music_volume_db


func set_sfx_volume(value_db: float) -> void:
	sfx_volume_db = clampf(value_db, -40.0, 0.0)
	button_sfx.volume_db = sfx_volume_db


func set_voice_volume(value_db: float) -> void:
	voice_volume_db = clampf(value_db, -30.0, 3.0)
	voice_player.volume_db = voice_volume_db


func play_menu_music() -> void:
	if not sound_enabled:
		return
	if menu_music.stream == null:
		menu_music.stream = load(MENU_MUSIC_PATH) as AudioStream
		if menu_music.stream == null:
			return
		if menu_music.stream is AudioStreamMP3:
			(menu_music.stream as AudioStreamMP3).loop = true
	if not menu_music.playing:
		menu_music.play()


func play_menu_intro() -> void:
	if menu_intro_played:
		play_menu_music()
		return
	menu_intro_played = true
	if not sound_enabled:
		return
	menu_intro.stream = load(MENU_INTRO_PATH) as AudioStream
	if menu_intro.stream:
		menu_intro.play()
	else:
		play_menu_music()


func _play_menu_music_after_intro() -> void:
	play_menu_music()


func play_button() -> void:
	_warm_up_tts()
	if not sound_enabled:
		return
	if button_sfx.stream == null:
		button_sfx.stream = load(BUTTON_SOUND_PATH) as AudioStream
	if button_sfx.stream:
		button_sfx.stop()
		button_sfx.play()


# ---------- Suara sapaan baru ----------

# Panggil saat tombol "Mulai" di halaman utama ditekan.
func play_welcome() -> void:
	_play_voice_delayed(WELCOME_ID, WELCOME_TEXT, WELCOME_DELAY)


# Panggil saat halaman utama Level 1 sudah tampil.
func play_level1_intro() -> void:
	_play_voice_delayed(LEVEL1_INTRO_ID, LEVEL1_INTRO_TEXT, LEVEL1_INTRO_DELAY)


func _play_voice_delayed(audio_id: String, text: String, delay: float) -> void:
	# Token dipakai supaya kalau pemain pindah halaman / suara di-stop
	# sebelum jeda selesai, suara lama tidak ikut keputar.
	_delayed_voice_token += 1
	var my_token := _delayed_voice_token
	await get_tree().create_timer(delay).timeout
	if my_token != _delayed_voice_token:
		return
	play_audio(audio_id, text, true)


# Suara pembuka Level 2-4 dan Buku Koleksi (file: res://audio/voice/ui/<id>.mp3).
func play_intro(intro_id: String) -> void:
	var texts := {
		"level2_intro": "Ayo dengarkan suaranya, lalu pilih huruf yang benar!",
		"level3_intro": "Ayo pasangkan huruf besar dengan huruf kecil!",
		"level4_intro": "Ayo belajar menulis huruf!",
		"collection_intro": "Ini Buku Koleksi hurufmu!"
	}
	_play_voice_delayed("ui/%s" % intro_id, str(texts.get(intro_id, "")), 0.15)


func play_instruction(activity_id: String, text: String) -> void:
	play_audio("instructions/%s" % activity_id, text, true)


func play_letter(letter: String) -> void:
	play_audio("letters/%s" % letter.to_upper(), "%s!" % letter.to_upper(), true)


# Suara kartu abjad bergambar Level 1 (nama benda sesuai gambar).
func play_card_word(letter: String) -> void:
	var word := AlphabetData.card_word(letter)
	var audio_id := "words/%s" % word.to_upper()
	# Kalau rekaman audio/voice/words/APEL.mp3 (dst.) ada, pakai rekaman itu.
	if _load_voice_stream(audio_id) != null:
		play_audio(audio_id, "%s!" % word, true)
		return
	# Belum ada rekaman: ucapkan nama bendanya dengan suara bahasa Indonesia dari browser.
	last_audio_id = audio_id
	last_audio_text = "%s!" % word
	queued_audio.clear()
	if voice_player.playing:
		voice_player.stop()
	_speak_with_tts(str(SPOKEN_WORDS.get(word.to_upper(), word)))


func play_word(word: String) -> void:
	play_audio("words/%s" % word.to_upper(), "%s!" % word.capitalize(), true)


const TTS_PITCH := 1.7  # nada tinggi: suara anak perempuan
const TTS_RATE := 1.0

var _tts_warmed := false

# JS dipasang sekali: memilih suara bahasa Indonesia (prioritas suara lokal/perempuan
# supaya cepat), lalu menyiapkan fungsi bicara dan berhenti.
const TTS_JS_SETUP := """
(function () {
  if (window.literakuSpeak) { return; }
  var chosen = null;
  function score(v) {
    var s = 0;
    if (v.localService) { s += 4; }
    if (/gadis|damayanti|female|wanita|perempuan/i.test(v.name)) { s += 3; }
    if (/andika|male|pria|laki/i.test(v.name)) { s -= 3; }
    return s;
  }
  function pick() {
    if (!window.speechSynthesis) { return; }
    var all = speechSynthesis.getVoices();
    var pool = all.filter(function (v) { return /^(id|in)([-_]|$)/i.test(v.lang); });
    if (!pool.length) { pool = all.filter(function (v) { return /^ms([-_]|$)/i.test(v.lang); }); }
    pool.sort(function (a, b) { return score(b) - score(a); });
    chosen = pool[0] || null;
  }
  pick();
  if (window.speechSynthesis) { speechSynthesis.onvoiceschanged = pick; }
  window.literakuStop = function () {
    try { if (speechSynthesis.speaking || speechSynthesis.pending) { speechSynthesis.cancel(); } } catch (e) {}
  };
  window.literakuSpeak = function (text, pitch, rate, volume) {
    try {
      if (!window.speechSynthesis) { return; }
      window.literakuStop();
      var u = new SpeechSynthesisUtterance(text);
      u.lang = 'id-ID';
      if (chosen) { u.voice = chosen; }
      u.pitch = pitch; u.rate = rate; u.volume = volume;
      speechSynthesis.speak(u);
    } catch (e) {}
  };
})();
"""


func _tts_setup() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(TTS_JS_SETUP)


func _tts_stop() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (window.literakuStop) { window.literakuStop(); }")
	elif DisplayServer.get_name() != "headless":
		DisplayServer.tts_stop()


# Dipanggil pada tekanan tombol pertama (gesture pemain) supaya mesin suara browser
# sudah "hangat" dan suara benda langsung keluar tanpa jeda.
func _warm_up_tts() -> void:
	if _tts_warmed:
		return
	_tts_warmed = true
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (window.literakuSpeak) { window.literakuSpeak(' ', 1, 1, 0); }")


func _speak_with_tts(text: String) -> void:
	if not sound_enabled:
		return
	var spoken := text + "!"
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (window.literakuSpeak) { window.literakuSpeak(%s, %s, %s, 1); }" % [JSON.stringify(spoken), TTS_PITCH, TTS_RATE])
	elif DisplayServer.get_name() != "headless":
		var voice_id := ""
		for language in ["id", "in", "ms"]:
			var voices := DisplayServer.tts_get_voices_for_language(language)
			if not voices.is_empty():
				voice_id = voices[0]
				break
		DisplayServer.tts_speak(spoken, voice_id, 100, TTS_PITCH, TTS_RATE, 0, true)


func play_feedback_correct(text := "Hebat! Kamu berhasil!") -> void:
	play_audio("feedback/correct", text, true)


func play_feedback_retry(text := "Belum tepat. Yuk, coba lagi!") -> void:
	play_audio("feedback/retry", text, true)


func play_transition(text := "Bagus! Sekarang kita lanjut ke soal berikutnya!") -> void:
	play_audio("feedback/transition", text, true)


func play_encouragement(text := "Kamu pasti bisa. Coba lagi, ya!") -> void:
	play_audio("feedback/encouragement", text, true)


func play_success() -> void:
	play_feedback_correct()


func stop_audio() -> void:
	_delayed_voice_token += 1  # batalkan suara yang masih menunggu jeda
	_tts_stop()
	queued_audio.clear()
	if voice_player.playing:
		voice_player.stop()


func replay_last_audio() -> void:
	if not last_audio_id.is_empty():
		play_audio(last_audio_id, last_audio_text, true)


func play_audio(audio_id: String, fallback_text: String, interrupt := true) -> void:
	last_audio_id = audio_id
	last_audio_text = fallback_text
	if interrupt:
		queued_audio.clear()
		_tts_stop()
		if voice_player.playing:
			voice_player.stop()
		_play_voice_or_fallback(audio_id, fallback_text)
	else:
		queued_audio.append({"id": audio_id, "text": fallback_text})
		if not voice_player.playing:
			_play_next_queued_audio()


func _play_voice_or_fallback(audio_id: String, fallback_text: String) -> void:
	if not sound_enabled:
		return
	var stream := _load_voice_stream(audio_id)
	if stream:
		voice_player.stream = stream
		voice_player.play()
	else:
		# Rekaman belum tersedia: UI tetap memberi instruksi yang sama dan game tidak error.
		narration_requested.emit(fallback_text)
		print("[Voice fallback] %s: %s" % [audio_id, fallback_text])


func _load_voice_stream(audio_id: String) -> AudioStream:
	for extension in ["ogg", "mp3", "wav"]:
		var path := "res://audio/voice/%s.%s" % [audio_id, extension]
		if ResourceLoader.exists(path):
			return load(path) as AudioStream
	return null


func _play_next_queued_audio() -> void:
	if queued_audio.is_empty():
		return
	var next: Dictionary = queued_audio.pop_front()
	_play_voice_or_fallback(next.id, next.text)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_register_button(node)


func _register_existing_buttons() -> void:
	_register_buttons_in(get_tree().root)


func _register_buttons_in(parent: Node) -> void:
	for child in parent.get_children():
		if child is BaseButton:
			_register_button(child)
		_register_buttons_in(child)


func _register_button(button: BaseButton) -> void:
	if button.has_meta("literaku_click_sound"):
		return
	button.set_meta("literaku_click_sound", true)
	button.pressed.connect(play_button)
