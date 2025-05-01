extends Control

func _ready():
	SignalBus.connect("fiscalYearEnd", _onYearEnd)
	
func _onYearEnd():
	self.visible = true
	$AnimationPlayer.play("fadeIn")
	print("year end")
