extends CanvasLayer

const CHAR_READ_RATE = 0.05

var textbox_container
var start_symbol
var end_symbol
var label
var tween
var time

enum State {
	READY,
	READING,
	FINISHED
}

var tut1 = load("res://assets/Tutorial/tut_1.png")
var tut2 = load("res://assets/Tutorial/tut_2.png")
var tut3 = load("res://assets/Tutorial/tut_3.png")
var tut4 = load("res://assets/Tutorial/tut_4.png")
var tut5 = load("res://assets/Tutorial/tut_5.png")

var current_state = State.READY
var text_queue = []

func _ready() -> void:
	textbox_container = $TextboxContainer
	start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
	end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
	label = $TextboxContainer/MarginContainer/HBoxContainer/Label

	$"../Music".playDelay()

	print("Starting State: READY")

	hide_textbox()

	await get_tree().create_timer(0.5).timeout

	queue_text("Welcome to your office, President! Press the [ENTER] key to continue.")
	queue_text("First, let's give you a quick tour of your surroundings.")

	queue_text("This is the main office, where you will be spending most of your time.")
	queue_text("To your left, you will find a stack of papers.")
	queue_text("These papers are bills that were submitted by the legislative branch for your approval.")
	queue_text("To review them, click on the stack.")
	queue_text("Here, you can see the title, type, and a short description of each bill.")

	queue_text("Here, you can see the policies that are waiting for your approval or denial.")
	queue_text("To approve a policy, click on the green stamp and stamp the paper.")
	queue_text("To deny a policy, click on the red stamp and stamp the paper.")
	queue_text("Clicking on the [Look Outside] button will allow you to see the outside world.")

	queue_text("You can look outside the window to gauge the effects of your decision-making on your country.")

	queue_text("Going back to the office, you will see a [Computer] button.")
	queue_text("Clicking on it will take you to the computer room.")

	queue_text("Here, you can see the current statistics of the economy.")
	queue_text("Note that this computer only updates every fiscal quarter!")
	queue_text("That is all for the tutorial. You may now begin to review the policies. Decide wisely, President.")


func _process(delta):
	match current_state:
		State.READY:
			if text_queue.size() > 0:
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				$"../TextscrollSFX".stop()
				label.visible_ratio = 1
				tween.stop()
				end_symbol.text = "v"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				hide_textbox()
				if text_queue.size() == 0:
					print("Tutorial finished.")
					LoadManager.load_scene("res://scenes/start_menu.tscn")

func change_texture(t):
	$Sprite2D.texture = t

func queue_text(text):
	text_queue.append(text)

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.visible = false

func show_textbox():
	start_symbol.text = "*"
	textbox_container.visible = true

func display_text():
	var text = text_queue.pop_front()
	time = text.length() * CHAR_READ_RATE
	tween = get_tree().create_tween()
	tween.connect("finished", _on_tween_finished)
	label.text = text
	label.visible_ratio = 0.0
	change_state(State.READING)
	show_textbox()
	tween.tween_property(label, "visible_ratio", 1, time)
	$"../TextscrollSFX".play()
	if text == "Here, you can see the policies that are waiting for your approval or denial.":
		change_texture(tut2)
	elif text == "You can look outside the window to gauge the effects of your decision-making on your country.":
		change_texture(tut3)
	elif text == "Going back to the office, you will see a [Computer] button.":
		change_texture(tut1)
	elif text == "Here, you can see the current statistics of the economy.":
		change_texture(tut4)
	
func _on_tween_finished():
	end_symbol.text = "v"
	$"../TextscrollSFX".stop()
	change_state(State.FINISHED)

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("State: READY")
		State.READING:
			print("State: READING")
		State.FINISHED:
			print("State: FINISHED")
