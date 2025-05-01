extends Control
var AggregateChanges: Dictionary
var economicVariables = [    
	"main_econ_GDP",
	"main_econ_PopulationSatisfaction",
	"inflation_rate",
	"growth_multiplier",
	"tax_rate",
	"unemployment",
	"gov_debt",
	"ag_demand",
	"ag_supply",
	"net_exports",
	"currency_value"]
func _ready():
	SignalBus.connect("fiscalYearEnd", _onYearEnd)
	
func _onYearEnd(compiledBills):
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
	displayDataChanges()
func displayDataChanges():
	var animation_duration = 0.5  # seconds
	var frames = int(animation_duration / get_process_delta_time())  # how many frames we have
	for i in range($Stats.get_child_count()):
		var var_name = economicVariables[i]
		if AggregateChanges.has(var_name):
			var target_value = AggregateChanges[var_name]
			var current_value = 0.0
			var use_percent = abs(target_value) < 1.0
			var step = (target_value - current_value) / frames
			for j in range(frames):
				current_value += step
				if j == frames - 1:
					current_value = target_value
				var sign_text
				if current_value >= 0:
					$Labels.get_child(i).modulate = Color.html("#42f575")
					sign_text = "+"	
				else:
					$Labels.get_child(i).modulate = Color.html("#ff2b2b")
					sign_text = "-"
				
				var display_value = ""
				if use_percent:
					display_value = str(abs(current_value * 100)).pad_decimals(1) + "%"
				else:
					display_value = str(round(abs(current_value)))
				$Stats.get_child(i).text = sign_text + display_value
				await get_tree().process_frame  
		else:
			await get_tree().create_timer(animation_duration/4).timeout
			$Labels.get_child(i).modulate = Color.html("#4d4d4d")
			$Stats.get_child(i).text = str(0)
			await get_tree().create_timer(animation_duration/4).timeout
