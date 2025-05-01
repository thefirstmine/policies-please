extends Control

func _ready():
	$"CreditsMusic".stream = load("res://assets/Audio/credits.wav")
	$"CreditsMusic".play()
