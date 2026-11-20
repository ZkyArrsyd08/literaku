extends Control

@onready var info_popup: PanelContainer = %InfoPopup


func _ready() -> void:
	%BackButton.pressed.connect(func() -> void: GameManager.go_to("main_menu"))
	%LetterButton.text = "Audio"
	%LetterButton.pressed.connect(func() -> void: GameManager.open_screen("listen_find"))
	%WritingButton.text = "Pilih Kapital dan Tidak"
	%WritingButton.pressed.connect(func() -> void: GameManager.open_screen("letter_pairs"))
	%ClosePopupButton.pressed.connect(func() -> void: info_popup.hide())

	var cards := get_node("Cards") as HBoxContainer
	cards.offset_left = 100
	cards.offset_right = -100
	var pencil_button := Button.new()
	pencil_button.name = "PencilHomeButton"
	pencil_button.text = "✏  Rumah Pensil"
	pencil_button.custom_minimum_size = Vector2(230, 110)
	pencil_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pencil_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pencil_button.add_theme_font_size_override("font_size", 24)
	pencil_button.pressed.connect(func() -> void: GameManager.open_screen("pencil_home"))
	cards.add_child(pencil_button)


func _show_popup(title: String, message: String) -> void:
	%PopupTitle.text = title
	%PopupMessage.text = message
	info_popup.show()
	info_popup.scale = Vector2(0.9, 0.9)
	create_tween().tween_property(info_popup, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
