extends Control
var EconomyData
var badOutside = load("res://assets/Art/windowState-Bad.png")
var neutralOutside = load("res://assets/Art/windowState-Neutral.png")
var goodOutside = load("res://assets/Art/windowState-Good.png")

func _requestedEconomyData(EconomyValues):
	EconomyData = EconomyValues
func _ready():
	SignalBus.connect("deliverEconomyData", _requestedEconomyData)
	SignalBus.connect("newFiscalYear", _onYearStart)
	updateWindow()
func _onYearStart():
	updateWindow()
func updateWindow():
	await get_tree().create_timer(.1).timeout
	SignalBus.emit_signal("requestEconomyData")
	print(EconomyData)
	print(EconomyData["GDP"])
	
	if EconomyData["GDP"] <= 800:
		$Outside.texture = badOutside
	elif 800 <= EconomyData["GDP"] and EconomyData["GDP"]  <= 1300:
		$Outside.texture = neutralOutside
	elif 1300 <= EconomyData["GDP"]:
		$Outside.texture = goodOutside
