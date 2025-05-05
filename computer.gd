extends Control

func _ready():
	pass
	


func _on_computer_pressed() -> void:
	$AnimationPlayer.play("Zoom In")
	$Computer.disabled = true
