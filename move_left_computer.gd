extends Button

func _on_pressed() -> void:
	$"../../../SFX1".stream = load("res://assets/Audio/uihoversfx.wav")
	$"../../../SFX1".play()
	get_parent().visible = false
