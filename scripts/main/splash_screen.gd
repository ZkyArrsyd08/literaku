extends Control

@export_range(1.0, 6.0, 0.1) var display_time := 2.6

@onready var logo: TextureRect = %Logo
@onready var lumi: Control = %Lumi


func _ready() -> void:
	logo.modulate.a = 0.0
	lumi.scale = Vector2(0.45, 0.45)
	lumi.modulate.a = 0.0

	var intro := create_tween().set_parallel(true)
	intro.tween_property(logo, "modulate:a", 1.0, 0.45)
	intro.tween_property(lumi, "modulate:a", 1.0, 0.35).set_delay(0.1)
	intro.tween_property(lumi, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(display_time).timeout
	GameManager.go_to("main_menu")
