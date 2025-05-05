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
var isNuclear = false
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
	#print("Compiled Bills:")
	print(compiledBills)
	for i in compiledBills:
		if i["name"] == "Nuclear Bomb Detonation at the Nation's Capital":
			isNuclear = true
			print("Its going to get nuclear")
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
	if isNuclear:
		$Doom.visible = true
		ChangedEconomyData = {
			"GDP": -9999,
			"PopulationSatisfaction": -9999,
			"taxRate": -9999,
			"unemployment": 9999,
			"govDebt": 9999,
			"agDemand": -9999,
			"agSupply": -9999,
			"netExports": -9999,
			"growthMultiplier": -9999,
			"inflation": -9999,
			"currencyValue": -9999
		}
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
func _on_next_pressed():
	if FiscalQuarterNumber == 5 or isNuclear:
		Ending()
		return 0
	self.visible = false
	$"../BlackScreen".modulate = Color(1, 1, 1, 1)
	$"../BlackScreen/Text".visible = true	
	$"../BlackScreen/Text".text = "Fiscal Quarter " + str(FiscalQuarterNumber)
	print("next")
	SFX.pitch_scale = 1
	SFX.stream = load("res://assets/Audio/Flash.ogg")
	SFX.play()
	await get_tree().create_timer(2).timeout
	SignalBus.emit_signal("newFiscalYear")
	$"../AnimationPlayer".play("fade_to_normal")
	await get_tree().create_timer(1.5).timeout
	$"../BlackScreen".visible = false
	
func Ending():
	print("ENDING")
	print(newEconomyData)
	$Labels.visible = false
	$Stats.visible = false
	$Results.visible = false
	$Next.visible = false
	$Ending.visible = true
	SignalBus.emit_signal("requestEconomyData")
	print(newEconomyData)
	if isNuclear:
		Ending_Nuclear()
	elif newEconomyData["GDP"] <= 700:
		Ending_Depression()
	elif newEconomyData["PopulationSatisfaction"] <= .15:
		Ending_Exile()
	elif newEconomyData["GDP"] >= 1600:
		Ending_Prosperity()
	else:
		Ending_Stagnation()
	
func Ending_Nuclear():
	var Music = load("res://assets/Audio/EndingBad.mp3")
	$Ending/Banner.texture = load("res://assets/Art/ending_nuke.png")
	$EndingMusic.stream = Music
	$EndingMusic.play()
	$Ending.text = "Ending 5 - Nuclear"
	$"Ending/Description".text = "Dude. Really? You would just set off a nuclear bomb on your own country? Get it together, man."
	$"Ending/Description2".text = ""
func Ending_Depression():
	var Music = load("res://assets/Audio/Ending_Bad2.mp3")
	$Ending/Banner.texture = load("res://assets/Art/ending_depression.png")
	$EndingMusic.stream = Music
	$EndingMusic.play()
	$Ending.text = "Ending 2 - Depression"
	$"Ending/Description".text = "Under your management, the economy took a turn for the very, very bad, and you've made your people very, very unhappy. On the one-year anniversary of your administration, your citizens stormed the gates of your office to clamor for change. Amidst the chaos, a protester chucked a Molotov at your window, causing the entire office to erupt in flames. "
	$"Ending/Description2".text = "...Maybe politics just isn't for you."

func Ending_Exile():
	var Music = load("res://assets/Audio/EndingNeutral.wav")
	$Ending/Banner.texture = load("res://assets/Art/ending_impeachment.png")
	$EndingMusic.stream = Music
	$EndingMusic.play()
	$Ending.text = "Ending 3 - Impeachment"
	$"Ending/Description".text = "Despite your efforts to improve the economy, the citizens of your nation started to despise your leadership. The citizens felt oppressed, unsatisfied, and discontent under your leadership due to the policies you decided to pass. This may be a bad outcome for you, but may bring forth a turn of a new leaf for the country that you are no longer apart of."
	$"Ending/Description2".text = ""

func Ending_Stagnation():
	var Music = load("res://assets/Audio/EndingNeutral.wav")
	$EndingMusic.stream = Music
	$EndingMusic.play()
	$Ending.text = "Ending 1 - Stagnation"
	$"Ending/Description".text = "The year ends, and while your country is no longer the brink of collapse, there is a lull in economic growth. Thankfully, your citizens seem content enough with your leadership. After three more mediocre years, your term ends, and you retire peacefully. Hopefully, a better leader will take your place."
	$"Ending/Description2".text = ""

func Ending_Prosperity():
	var Music = load("res://assets/Audio/EndingGood.wav")
	$EndingMusic.stream = Music
	$EndingMusic.play()
	$Ending.text = "Ending 4 - Prosperity"
	$"Ending/Description".text = "After a year fraught with challenges and instability, you were able to save your nation from an economic recession with your astute judgement and understanding of economic policies. Not only that, but your citizens have decided to celebrate this bright new age by creating a 16-foot tall statue of your likeness. You will be remembered by your country for centuries to come. Congratulations, and soak in your victory!"
	$"Ending/Description2".text = ""


func _on_again_pressed() -> void:
	LoadManager.load_scene("res://scenes/start_menu.tscn")
