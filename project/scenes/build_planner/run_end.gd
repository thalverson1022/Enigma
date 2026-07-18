extends Control
## P2:M5 T3: single win/loss end screen (not two separate scenes) -- call
## show_result(won) after instantiating. "Restart" resets BuildState and
## hands control back to build_planner.gd.

signal restart_pressed

var _result_label: Label


func _ready() -> void:
	var vbox := VBoxContainer.new()
	add_child(vbox)

	_result_label = Label.new()
	vbox.add_child(_result_label)

	var restart_button := Button.new()
	restart_button.text = "Restart"
	restart_button.pressed.connect(func(): restart_pressed.emit())
	vbox.add_child(restart_button)


func show_result(won: bool) -> void:
	_result_label.text = "Victory!" if won else "Defeat"
