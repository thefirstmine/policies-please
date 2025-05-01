extends Control



func _on_paper_stack_toggled(toggled_on: bool) -> void:
	SignalBus.emit_signal("displayBill", toggled_on)


func _on_stamp_approve_toggled(toggled_on: bool) -> void:
	$"../../SFX1".stream = load("res://assets/Audio/mouseHover.wav")
	$"../../SFX1".play()
	SignalBus.emit_signal("StampSelected_Approve", toggled_on)
	if $StampDeny.button_pressed:
		$StampDeny.button_pressed = false
		SignalBus.emit_signal("StampSelected_Deny", false)
func _on_stamp_deny_toggled(toggled_on: bool) -> void:
	$"../../SFX1".stream = load("res://assets/Audio/mouseHover.wav")
	$"../../SFX1".play()
	SignalBus.emit_signal("StampSelected_Deny", toggled_on)
	if $StampApprove.button_pressed:
		$StampApprove.button_pressed = false
		SignalBus.emit_signal("StampSelected_Approve", false)

func _on_stamp_mouse_entered() -> void:
	pass
