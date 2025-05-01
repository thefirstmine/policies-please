extends Control

func _ready():
	SignalBus.connect("displayPolicy", _on_policyDisplay)

func _on_paper_pressed() -> void:
	SignalBus.emit_signal("policyPressed")


func _on_policyDisplay(policyData):

	$Paper/Title.text = policyData["name"]
	$Paper/Body.text = policyData["description"]
	$Paper/Type.text = "Type: " + policyData["type"].to_upper()
	if policyData["type"] == "Fiscal":
		$Paper/Type.modulate = Color(.2, .2, 1, 1)
	if policyData["type"] == "Monetary":
		$Paper/Type.modulate = Color(1, .2, .2, 1)
	if policyData["type"] == "Market-Managing":
		$Paper/Type.modulate = Color(.5, .5, .1, 1)
	if policyData["type"] == "Trade Policy":
		$Paper/Type.modulate = Color(.1, .7, .1, 1)
