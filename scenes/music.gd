extends AudioStreamPlayer

func playDelay():
	await get_tree().create_timer(1).timeout
	play()
func _on_finished() -> void:
	play()
