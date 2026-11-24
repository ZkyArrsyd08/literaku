extends Node

## Central place for scene navigation. Add new scenes here as each activity is built.
const SCENES := {
	"splash": "res://scenes/main/splash_screen.tscn",
	"main_menu": "res://scenes/main/main_menu.tscn",
	"activity_menu": "res://scenes/learning/activity_menu.tscn",
	"game": "res://scenes/game/game_screen.tscn",
}

var current_screen := "learning_selection"
var welcome_pending := false
var level1_intro_pending := false
var selected_letter := "A"
var selected_case := "upper"
var difficulty := "easy"
var level2_progress := 0
var level2_round_letters: Array[String] = []
var level3_completed: Dictionary = {}


func _ready() -> void:
	_enable_auto_fullscreen_landscape()


# Browser hanya mengizinkan layar penuh setelah ada sentuhan/klik pemain, jadi
# layar penuh + kunci landscape dipasang pada sentuhan pertama di mana saja.
# (Kunci landscape berjalan di Chrome Android; iPhone/iPad tidak mendukungnya.)
func _enable_auto_fullscreen_landscape() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval(AUTO_FULLSCREEN_JS)


<<<<<<< HEAD
# Tombol layar penuh: sekali tekan masuk layar penuh, tekan lagi keluar.
func toggle_fullscreen() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(TOGGLE_FULLSCREEN_JS)
		return
	if DisplayServer.get_name() == "headless":
		return
	var is_full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if is_full else DisplayServer.WINDOW_MODE_FULLSCREEN)


const TOGGLE_FULLSCREEN_JS := """
(function () {
  var d = document, el = d.documentElement;
  var current = d.fullscreenElement || d.webkitFullscreenElement;
  function lockLandscape() {
    try { screen.orientation.lock('landscape').catch(function () {}); } catch (e) {}
  }
  if (current) {
    var exit = d.exitFullscreen || d.webkitExitFullscreen;
    if (exit) { try { exit.call(d); } catch (e) {} }
    try { screen.orientation.unlock(); } catch (e) {}
  } else {
    var req = el.requestFullscreen || el.webkitRequestFullscreen;
    if (!req) { return; }
    try {
      var p = req.call(el);
      if (p && p.then) { p.then(lockLandscape).catch(function () {}); } else { lockLandscape(); }
    } catch (e) {}
  }
})();
"""


=======
>>>>>>> origin/main
const AUTO_FULLSCREEN_JS := """
(function () {
  if (window.literakuFsInstalled) { return; }
  window.literakuFsInstalled = true;
  var events = ['pointerup', 'touchend', 'click'];
  function lockLandscape() {
    try {
      if (screen.orientation && screen.orientation.lock) {
        screen.orientation.lock('landscape').catch(function () {});
      }
    } catch (e) {}
  }
  function done() {
    events.forEach(function (t) { document.removeEventListener(t, go, true); });
  }
  function go() {
    var el = document.documentElement;
    if (document.fullscreenElement || document.webkitFullscreenElement) {
      lockLandscape(); done(); return;
    }
    var req = el.requestFullscreen || el.webkitRequestFullscreen;
    if (!req) { lockLandscape(); return; }
    try {
      var p = req.call(el);
      if (p && p.then) {
        p.then(function () { lockLandscape(); done(); }).catch(function () {});
      } else {
        lockLandscape(); done();
      }
    } catch (e) {}
  }
  events.forEach(function (t) { document.addEventListener(t, go, true); });
})();
"""


func set_difficulty(value: String) -> void:
	if value in ["easy", "medium", "challenge"]:
		difficulty = value


func choice_count() -> int:
	return int({"easy": 3, "medium": 4, "challenge": 5}.get(difficulty, 3))


func difficulty_label() -> String:
	return str({"easy": "Mudah", "medium": "Sedang", "challenge": "Tantangan"}.get(difficulty, "Mudah"))


func go_to(scene_id: String) -> void:
	if not SCENES.has(scene_id):
		push_warning("Scene id tidak ditemukan: %s" % scene_id)
		return
	get_tree().change_scene_to_file(SCENES[scene_id])


func quit_game() -> void:
	AudioManager.stop_audio()
	if OS.has_feature("web"):
		# Tutup tab. Browser hanya mengizinkan window.close() untuk tab yang dibuka
		# lewat script, jadi kalau gagal, pindah ke halaman kosong sebagai "keluar".
		JavaScriptBridge.eval("try { window.open('', '_self'); window.close(); } catch (e) {} setTimeout(function () { window.location.replace('about:blank'); }, 250);")
		return
	get_tree().quit()


func open_screen(screen_id: String, letter := "", letter_case := "") -> void:
	current_screen = screen_id
	if not letter.is_empty():
		selected_letter = letter.to_upper()
	if not letter_case.is_empty():
		selected_case = letter_case
	get_tree().change_scene_to_file(SCENES["game"])
