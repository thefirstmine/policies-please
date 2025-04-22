extends Control


func _on_paper_pressed() -> void:
	print("test")
	SignalBus.emit_signal("policyPressed")
