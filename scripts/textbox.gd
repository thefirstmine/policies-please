extends CanvasLayer

const CHAR_READ_RATE = 0.05

var textbox_container
var start_symbol
var end_symbol
var label
var tween

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []

func _ready() -> void:
	textbox_container = $TextboxContainer
	start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
	end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
	label = $TextboxContainer/MarginContainer/HBoxContainer/Label

	print("Starting State: READY")

	hide_textbox()
	queue_text("crazy? i was crazy once. they locked me in a room. a rubber room")
	queue_text("a rubber room full of rats.")
	queue_text("and rats make me crazy!")

func _process(delta):
	match current_state:
		State.READY:
			if text_queue.size() > 0:
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.visible_ratio = 1
				tween.stop()
				end_symbol.text = "v"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				hide_textbox()

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
	tween = get_tree().create_tween()
	tween.connect("finished", _on_tween_finished)
	label.text = text
	label.visible_ratio = 0.0
	change_state(State.READING)
	show_textbox()
	tween.tween_property(label, "visible_ratio", 1, text.length() * CHAR_READ_RATE)

func _on_tween_finished():
	end_symbol.text = "v"
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
