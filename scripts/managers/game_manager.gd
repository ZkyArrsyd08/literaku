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
	get_tree().quit()


func open_screen(screen_id: String, letter := "", letter_case := "") -> void:
	current_screen = screen_id
	if not letter.is_empty():
		selected_letter = letter.to_upper()
	if not letter_case.is_empty():
		selected_case = letter_case
	get_tree().change_scene_to_file(SCENES["game"])
