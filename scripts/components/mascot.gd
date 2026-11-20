extends Control

## Gentle idle motion shared by every scene that displays Lumi.
@export var floating_distance := 6.0
@export var floating_duration := 0.9

@onready var image: TextureRect = %Image


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var float_tween := create_tween().set_loops()
	float_tween.tween_property(image, "position:y", -floating_distance, floating_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(image, "position:y", 0.0, floating_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
