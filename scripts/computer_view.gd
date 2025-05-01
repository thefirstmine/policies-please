extends Control

var economyData

func _ready():
	SignalBus.connect("deliverEconomyData", _requestedEconomyData)
	$Computer/ExitButton.visible = false
	$Computer.disabled = false

func _requestedEconomyData(EconomyValues):
	economyData = EconomyValues

func _on_texture_button_toggled(toggled_on: bool) -> void:
	$AnimationPlayer.play("zoom_in")
	await $AnimationPlayer.animation_finished
	$Computer/ExitButton.visible = true
	$Computer.disabled = true
	SignalBus.emit_signal("requestEconomyData")
	await get_tree().create_timer(0.25).timeout

func _on_exit_button_pressed() -> void:
	$Computer/ExitButton.visible = false
	$AnimationPlayer.play("zoom_out")
	await $AnimationPlayer.animation_finished
	$Computer.disabled = false
