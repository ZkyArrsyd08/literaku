class_name AlphabetData
extends RefCounted

const WORDS := ["Apel", "Bola", "Cicak", "Domba", "Elang", "Flaminggo", "Gajah", "Harimau", "Ikan", "Jeruk", "Kucing", "Lebah", "Mobil", "Nanas", "Obor", "Pisang", "Quran", "Roti", "Sapi", "Topi", "Ular", "Vas", "Wortel", "Xilofon", "Yoyo", "Zebra"]
const EMOJIS := ["🍎", "⚽", "🦎", "🐑", "🦅", "🦩", "🐘", "🐯", "🐟", "🍊", "🐱", "🐝", "🚗", "🍍", "🔥", "🍌", "📖", "🍞", "🐄", "🎩", "🐍", "🏺", "🥕", "🎼", "🪀", "🦓"]


# Nama benda persis seperti tulisan di kartu bergambar (assets/ui/alphabet/illustrated).
# Dipakai hanya untuk suara kartu abjad bergambar di Level 1.
const CARD_WORDS := ["Apel", "Bola", "Cacing", "Dinosaurus", "Elang", "Flaminggo", "Gajah", "Harimau", "Ikan", "Jeli", "Kangguru", "Landak", "Mangga", "Nanas", "Obor", "Panda", "Queen", "Robot", "Singa", "Tikus", "Ular", "Vas", "Wayang", "Xilofon", "Yoyo", "Zebra"]


static func card_word(letter: String) -> String:
	return CARD_WORDS[clampi(letter.to_upper().unicode_at(0) - 65, 0, 25)]


static func letters() -> PackedStringArray:
	return PackedStringArray("ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("", false))


static func info(letter: String) -> Dictionary:
	var index: int = maxi(0, letter.to_upper().unicode_at(0) - 65)
	return {"upper": letter.to_upper(), "lower": letter.to_lower(), "word": WORDS[index], "emoji": EMOJIS[index], "sentence": "%s untuk %s" % [letter.to_upper(), WORDS[index]]}


static func word_practice(difficulty := "easy") -> Array[Dictionary]:
	# Kosakata disusun per panjang kata agar tantangan naik perlahan, tanpa timer.
	var all_words: Array[Dictionary] = [
		{"word":"TAS", "emoji":"🎒"}, {"word":"JUS", "emoji":"🧃"}, {"word":"BIS", "emoji":"🚌"},
		{"word":"BOLA", "emoji":"⚽"}, {"word":"BUKU", "emoji":"📘"}, {"word":"MEJA", "emoji":"🪑"},
		{"word":"TOPI", "emoji":"🎩"}, {"word":"IKAN", "emoji":"🐟"}, {"word":"ROTI", "emoji":"🍞"},
		{"word":"SUSU", "emoji":"🥛"}, {"word":"KAKI", "emoji":"🦶"}, {"word":"MATA", "emoji":"👀"}, {"word":"GIGI", "emoji":"🦷"},
		{"word":"KURSI", "emoji":"🪑"}, {"word":"BUNGA", "emoji":"🌷"}, {"word":"RODA", "emoji":"🛞"}
	]
	var wanted_length := 3 if difficulty == "easy" else (4 if difficulty == "medium" else 5)
	var result: Array[Dictionary] = []
	for entry in all_words:
		if entry.word.length() == wanted_length:
			result.append(entry)
	return result if not result.is_empty() else all_words
