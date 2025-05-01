extends CanvasLayer

@onready var blur_rect = $BackBufferCopy/ColorRect
var score = 0

func _ready():
	# Плавное появление блюра
	var tween = create_tween()
	blur_rect.material.set_shader_parameter("blur_amount", 0)
	tween.tween_property(blur_rect.material, "shader_parameter/blur_amount", 3.0, 0.1)
	$VBoxContainer/ScoreLabel.text = "Score: " + str(score)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	queue_free()

func _on_exit_button_pressed():
	get_tree().quit()
