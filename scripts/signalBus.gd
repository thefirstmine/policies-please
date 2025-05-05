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
signal newFiscalYear()
#func _ready():
	#print("Game running!")
	#set_process_input(true) 
#
#func _input(ev):
	#if Input.is_key_pressed(KEY_F11):
		#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		#else:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
