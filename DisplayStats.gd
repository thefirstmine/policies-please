extends Control

@export var signalBus: Node2D
const COUNT_ECONOMY_STATS = 11
var economyLabels = []
func _ready():
	print("connecting...")
	signalBus.economyUpdated.connect(_on_economy_update)
	signalBus.switchPerspective.connect(_on_perspective_switch)

	var valueCount = 0

	for key in range(COUNT_ECONOMY_STATS):
		economyLabels.append(Label.new())
		economyLabels[valueCount].name = str(key)
		economyLabels[valueCount].position.y = (30*valueCount)
		self.add_child(economyLabels[valueCount])
		valueCount+=1

func _on_economy_update(EconomyValues):
	print("Economy Updated!")
	var valueCount = 0
	for key in EconomyValues:
		economyLabels[valueCount].text = str(key) + ": " + str(EconomyValues[key])
		valueCount += 1
func _on_perspective_switch(perspective):
	if perspective == -1:
		self.visible = true
	else:
		self.visible = false
