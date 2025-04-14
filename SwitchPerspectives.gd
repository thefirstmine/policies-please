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
		$"MoveLeft".modulate.a = 0
		$"MoveRight".modulate.a = 1
	elif Perspective == 1:
		$"MoveRight".modulate.a = 0
		$"MoveLeft".modulate.a = 1
	else:
		$"MoveLeft".modulate.a = 1
		$"MoveRight".modulate.a = 1
func _on_move_right_mouse_entered() -> void:
	print("Move Right Is Hovered")
	if Perspective <= 0:
		Perspective += 1
	print("Perspective:", Perspective)
	signalBus.switchPerspective.emit(Perspective)

	if Perspective == -1:
		$"MoveLeft".modulate.a = 0
		$"MoveRight".modulate.a = 1
	elif Perspective == 1:
		$"MoveRight".modulate.a = 0
		$"MoveLeft".modulate.a = 1
	else:
		$"MoveLeft".modulate.a = 1
		$"MoveRight".modulate.a = 1
