extends Control
var AggregateChanges: Dictionary
var economicVariables = [    
	"GDP",
	"PopulationSatisfaction",
	"inflation",
	"growthMultiplier",
	"taxRate",
	"unemployment",
	"govDebt",
	"agDemand",
	"agSupply",
	"netExports",
	"currencyValue"]
var oldEconomyData
var newEconomyData
var ChangedEconomyData
var SFX
var FiscalQuarterNumber: int = 1
func _ready():
	SFX = $"../../SFX2"

	SignalBus.connect("fiscalYearEnd", _onYearEnd)
	SignalBus.connect("deliverEconomyData", _requestedEconomyData)
	SignalBus.economyUpdated.connect(_on_economy_update)
func _requestedEconomyData(EconomyValues):
	oldEconomyData = EconomyValues
func _on_economy_update(EconomyValues):
	newEconomyData = EconomyValues
func get_economy_diff(old_data: Dictionary, new_data: Dictionary) -> Dictionary:
	var diff := {}
	for key in old_data.keys():
		if new_data.has(key):
			diff[key] = new_data[key] - old_data[key]
	return diff
func _onYearEnd(compiledBills):
	if FiscalQuarterNumber == 4:
		Ending()
		return 0
	$Results.texture = load("res://assets/Art/results"+ str(FiscalQuarterNumber) +".png")
	FiscalQuarterNumber+=1
	for i in $Labels.get_children():
		i.modulate = Color(1, 1, 1, 1)
	for i in $Stats.get_children():
		i.text = "0"
	$Next.disabled = true
	await get_tree().create_timer(2).timeout
	self.visible = true
	$AnimationPlayer.play("fadeIn")
	for i in range(0, len(compiledBills)): # for each Bill
		print(compiledBills[i]["data"])
		print("\n")
		for j in compiledBills[i]["data"].keys(): #
			if AggregateChanges.keys().has(j):
				AggregateChanges[j] += compiledBills[i]["data"][j]
			else:
				AggregateChanges[j] = compiledBills[i]["data"][j]
	print(AggregateChanges)
	SignalBus.emit_signal("requestEconomyData")
	SignalBus.emit_signal("processPolicy", AggregateChanges)

	ChangedEconomyData = get_economy_diff(oldEconomyData, newEconomyData)
	print("Changed Economy Data:", ChangedEconomyData)
	await get_tree().create_timer(.5).timeout
	displayDataChanges()
# List of positive and negative variables
var positive_vars = ["GDP", "PopulationSatisfaction", "growthMultiplier", "agSupply", "netExports"]
var negative_vars = ["unemployment", "govDebt"]
# Removed context-dependent logic

# Determines color based on variable type and change
func get_modulate_color(var_name: String, change: float) -> Color:
	if positive_vars.has(var_name):
		return Color.html("#42f575") if change > 0 else Color.html("#ff2b2b")
	elif negative_vars.has(var_name):
		return Color.html("#ff2b2b") if change > 0 else Color.html("#42f575")
	else:
		return Color.html("#42f575") if change > 0 else Color.html("#ff2b2b")

func displayDataChanges():
	var animation_duration = 0.5  # seconds
	var frames = int(animation_duration / get_process_delta_time())
	var increasing_pitch = 1
	for i in range($Stats.get_child_count()):
		var var_name = economicVariables[i]
		SFX.stream = load("res://assets/Audio/counter.wav")
		
		if ChangedEconomyData.has(var_name) and !(ChangedEconomyData[var_name] <= 0.01 and ChangedEconomyData[var_name] >= -0.01):
			var target_value = ChangedEconomyData[var_name]
			var current_value = 0.0
			var use_percent = abs(target_value) < 1.0
			var step = (target_value - current_value) / frames

			for j in range(frames):
				current_value += step
				if j == frames - 1:
					current_value = target_value

				var sign_text = "+" if current_value >= 0 else "-"
				var display_value = str(abs(current_value * 100)).pad_decimals(1) + "%" if use_percent else str(round(abs(current_value)))


				# Get color and pitch
				var color = get_modulate_color(var_name, target_value)
				$Labels.get_child(i).modulate = color
				$Stats.get_child(i).text = sign_text + display_value

				if !SFX.playing:
					if color == Color.html("#42f575"):
						SFX.stream = load("res://assets/Audio/counter.wav")
						if SFX.pitch_scale <= 6:
							SFX.pitch_scale = increasing_pitch
							increasing_pitch += 0.04
					else:
						SFX.stream = load("res://assets/Audio/err.wav")
						SFX.pitch_scale = 0.2
					SFX.play()

				await get_tree().process_frame
		else:
			await get_tree().create_timer(animation_duration / 2).timeout
			$Labels.get_child(i).modulate = Color.html("#4d4d4d")
			$Stats.get_child(i).text = str(0)
			SFX.pitch_scale = 0.15
			SFX.stream = load("res://assets/Audio/counter.wav")
			SFX.play()
			await get_tree().create_timer(animation_duration / 2).timeout
	await get_tree().create_timer(.5).timeout
	SFX.pitch_scale = 1
	SFX.stream = load("res://assets/Audio/enable.wav")
	SFX.play()
	$Next.disabled = false
func _on_next_pressed() -> void:
	
	self.visible = false
	$"../BlackScreen".modulate = Color(1, 1, 1, 1)
	$"../BlackScreen/Text".visible = true	
	$"../BlackScreen/Text".text = "Fiscal Quarter " + str(FiscalQuarterNumber)
	print("next")
	SFX.pitch_scale = 1
	SFX.stream = load("res://assets/Audio/Flash.ogg")
	SFX.play()
	await get_tree().create_timer(2).timeout
	
	$"../AnimationPlayer".play("fade_to_normal")
	await get_tree().create_timer(1.5).timeout
	$"../BlackScreen".visible = false
	SignalBus.emit_signal("newFiscalYear")
func Ending():
	print("ENDING")
	print(newEconomyData)
	SignalBus.emit_signal("requestEconomyData")
	print(newEconomyData)
