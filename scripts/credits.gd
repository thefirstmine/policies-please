extends Control

func _ready():
	$"CreditsMusic".stream = load("res://assets/Audio/credits.wav")
	$"CreditsMusic".play()


func _on_credits_music_finished() -> void:
	$"CreditsMusic".play()


func _on_back_pressed() -> void:
	LoadManager.load_scene("res://scenes/start_menu.tscn")


func _on_back_mouse_entered() -> void:
	$SFX.stream = load("res://assets/Audio/hover.wav")
	$SFX.play()


func _on_sources_pressed() -> void:
	$AnimationPlayer.play("GoToSources")


func _on_back_2_pressed() -> void:
	$AnimationPlayer.play("GoToCredits")
