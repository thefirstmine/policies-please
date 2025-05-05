extends Control
var EconomyData
func _ready():
	SignalBus.connect("deliverEconomyData", _requestedEconomyData)
	updateStats()


func _on_computer_pressed() -> void:
	$AnimationPlayer.play("Zoom In")
	$Computer.disabled = true
	$SFX.stream = load("res://assets/Audio/bootup.wav")
	$SFX.play()
	updateStats()

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Zoom In":
		#$ComputerScreen.scale.x = .5
		#$ComputerScreen.scale.y = 0.5
		$Computer.visible = false
		$MoveLeft.visible = false
		$Background.visible = false
		$ComputerScreen.visible = true
		SignalBus.emit_signal("requestEconomyData")
		$ComputerBuzzing.play()

		$ComputerScreen/Statistics.text = ("GDP: " + str(EconomyData["GDP"]) +"
Happiness: " + str(round_to_dec(EconomyData["PopulationSatisfaction"]*100, 2)) + "%" + "
Taxes: " + str(round_to_dec(EconomyData["taxRate"]*100, 2)) + "%"  +"
Unemployment: " + str(round_to_dec(EconomyData["unemployment"]*100, 2)) + "%"  +"
Government Debt: " + str(round_to_dec(EconomyData["govDebt"], 2)) +"
Aggregate Demand: " + str(round_to_dec(EconomyData["agDemand"], 2)) +"
Aggregate Supply: " + str(round_to_dec(EconomyData["agSupply"], 2)) +"
Total Exports: " + str(round_to_dec(EconomyData["netExports"], 2)) +"
Growth Multiplier: " + str(round_to_dec(EconomyData["growthMultiplier"]*100, 2)) + "%"  +"
Inflation: " + str(round_to_dec(EconomyData["inflation"]*100, 2)) + "%"  +"
Currency Value: " + str(round_to_dec(EconomyData["currencyValue"]*100, 2)) + "%"  +"
		")
		$AnimationPlayer.play("RemoveWhiteout")

func _on_back_mouse_entered() -> void:
	$SFX.stream = load("res://assets/Audio/hover.wav")
	$SFX.play()


func _on_back_pressed() -> void:
	$SFX.stream = load("res://assets/Audio/shutdown.wav")
	$SFX.play()
	$ComputerBuzzing.stop()
	$Computer.disabled = false
	$Computer.visible = true
	$MoveLeft.visible = true
	$Background.visible = true
	$ComputerScreen.visible = false
	$AnimationPlayer.play("Zoom Out")
	
	
func _requestedEconomyData(EconomyValues):
	EconomyData = EconomyValues

func updateStats():
	await get_tree().create_timer(.1).timeout
	SignalBus.emit_signal("requestEconomyData")
	print(EconomyData)


func _on_computer_buzzing_finished() -> void:
	$ComputerBuzzing.play()
