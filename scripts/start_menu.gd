extends Node3D

func _ready():
	$SFX.stream = load("res://assets/Audio/hover.wav")
	$"SubViewportContainer/SubViewport/Camera3D".position.y = 100.00
	$AnimationPlayer.play("cameraEaseIn")
	await get_tree().create_timer(.5).timeout
	$MenuMusic.stream = load("res://assets/Audio/menuMusic.wav")
	$MenuMusic.play()


func _on_menu_music_finished() -> void:
	$MenuMusic.play()


func _on_start_pressed() -> void:
	LoadManager.load_scene("res://scenes/main_game.tscn")
	
func _on_credits_pressed() -> void:
	LoadManager.load_scene("res://scenes/credits.tscn")

func _on_tutorial_pressed() -> void:
	LoadManager.load_scene("res://scenes/tutorial.tscn")

func _on_start_mouse_entered() -> void:
	$SFX.play()

func _on_credits_mouse_entered() -> void:
	$SFX.play()

func _on_tutorial_mouse_entered() -> void:
	$SFX.play()
