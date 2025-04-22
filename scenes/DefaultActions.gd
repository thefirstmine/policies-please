extends Control



func _on_paper_stack_toggled(toggled_on: bool) -> void:
	SignalBus.emit_signal("displayBill", toggled_on)


func _on_stamp_approve_toggled(toggled_on: bool) -> void:
	SignalBus.emit_signal("StampSelected_Approve", toggled_on)


func _on_stamp_deny_toggled(toggled_on: bool) -> void:
	SignalBus.emit_signal("StampSelected_Deny", toggled_on)
