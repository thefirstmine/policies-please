extends Node2D

signal economyUpdated(EconomyValues)
signal switchPerspective(Perspective)
signal displayBill(isDisplaying)
signal StampSelected_Deny(isSelected)
signal StampSelected_Approve(isSelected)
signal policyPressed()
signal displayPolicy(PolicyData)
signal newPolicy()
signal policyPassed()
signal broadcastCurrentPolicy()
signal fiscalYearEnd(compiledBills)
signal processPolicy(PolicyData)
signal requestEconomyData()
signal deliverEconomyData(Data)
#func _ready():
	#print("Game running")
	#
