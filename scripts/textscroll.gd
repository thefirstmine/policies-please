extends AudioStreamPlayer

#func playDelay():
	#print("playdelay")
	#volume_db = -5.0
	#play()
	#
	#print(is_playing())
	#print(volume_db)
func _on_finished() -> void:
	play()
	
