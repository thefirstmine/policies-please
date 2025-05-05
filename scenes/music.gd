extends AudioStreamPlayer

func playDelay():
	print("playdelay")
	volume_db = -5.0
	await get_tree().create_timer(1).timeout
	play()
	
	print(is_playing())
	print(volume_db)
func _on_finished() -> void:
	play()
	
