extends Node

const SAVE_PATH := "user://literaku_progress.json"
var learned: Dictionary = {}
var written: Dictionary = {}
var paired: Dictionary = {}
var words: Dictionary = {}
var activities: Dictionary = {}
var stickers: Dictionary = {}


func _ready() -> void:
	load_progress()


func mark_learned(letter: String) -> void:
	learned[letter.to_upper()] = true
	save_progress()


func mark_written(letter: String) -> void:
	written[letter.to_upper()] = true
	save_progress()


func mark_paired(letter: String) -> void:
	paired[letter.to_upper()] = true
	save_progress()


func mark_word(word: String) -> void:
	words[word.to_upper()] = true
	save_progress()


func mark_activity_complete(activity_id: String) -> void:
	activities[activity_id] = true
	# Stiker diberikan sekali untuk keberhasilan pertama di tiap aktivitas.
	stickers[activity_id] = true
	save_progress()


func sticker_count() -> int:
	return stickers.size()


func is_learned(letter: String) -> bool:
	return learned.has(letter.to_upper())


func is_written(letter: String) -> bool:
	return written.has(letter.to_upper())


func has_started_level_one() -> bool:
	# Level 1 dianggap selesai setelah seluruh 26 huruf dipelajari.
	return learned.size() >= 26


func is_level_unlocked(level_number: int) -> bool:
	match level_number:
		1:
			return true
		2:
			return is_level_completed(1)
		3:
			return is_level_completed(2)
		4:
			return is_level_completed(3)
	return false


func is_level_completed(level_number: int) -> bool:
	match level_number:
		1:
			return learned.size() >= 26
		2:
			return activities.has("listen_find")
		3:
			return activities.has("letter_pairs")
		4:
			return written.size() >= 26
	return false


func save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"learned": learned, "written": written, "paired": paired, "words": words, "activities": activities, "stickers": stickers}))


func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		learned = parsed.get("learned", {})
		written = parsed.get("written", {})
		paired = parsed.get("paired", {})
		words = parsed.get("words", {})
		activities = parsed.get("activities", {})
		stickers = parsed.get("stickers", {})
