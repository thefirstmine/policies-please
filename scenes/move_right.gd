extends Button



func _on_pressed() -> void:
	$"../../SFX1".stream = load("res://assets/Audio/uihoversfx.wav")
	$"../../SFX1".play()
	$"../Computer".visible = true
	print("erm")
