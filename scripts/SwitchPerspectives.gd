extends Control

@export var signalBus: Node2D

@export var Perspective: int = 0

func _ready():
	print("sigmfdihmdfsih")


func _on_move_left_mouse_entered() -> void:
	print("Move Left Is Hovered")
	if Perspective >= 0:
		Perspective -= 1
	print("Perspective:", Perspective)
	signalBus.switchPerspective.emit(Perspective)
	if Perspective == -1:
		showFiscalReport()
	elif Perspective == 1:
		showPolicyPassing()
	else:
		showDefault()
func _on_move_right_mouse_entered() -> void:
	print("Move Right Is Hovered")
	if Perspective <= 0:
		Perspective += 1
	print("Perspective:", Perspective)
	signalBus.switchPerspective.emit(Perspective)

	if Perspective == -1:
		showFiscalReport()
	elif Perspective == 1:
		showPolicyPassing()
	else:
		showDefault()
		
func showFiscalReport():
	$"MoveLeft".visible = false
	$"MoveRight".visible = true	
	$"../FiscalReport".visible = true
	$"../background".visible = false
func showPolicyPassing():
	$"MoveRight".visible = false
	$"MoveLeft".visible= true
	$"../PassingPolicies".visible = true

func showDefault():
	$"MoveLeft".visible= true
	$"MoveRight".visible= true
	$"../PassingPolicies".visible = false
	$"../FiscalReport".visible = false
	$"../background".visible = true
