class_name Letterbox extends Control

@onready var label_node = $MarginContainer/Label as Label
@onready var label_container_node = $MarginContainer as MarginContainer

signal choice_selected(choice: Dictionary)
signal next()

var letter_delay: float = 0.02
var letter_timer_counter: float = 0
var text = ""
var textbox_entry_timer = 0
var textbox_entry_timer_max = 0.25
var anchor_box_separation = 12
var extra_height = 0


func print_message(txt: String, pos: Vector2) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	global_position = pos 
	text = txt
	letter_timer_counter = letter_delay
	textbox_entry_timer = textbox_entry_timer_max
	size = viewport_size
	label_node.autowrap_mode = 2
	label_node.custom_minimum_size = Vector2(viewport_size.x * 0.8, 0.)

func erase_message():
	text = ""
	label_node.text = ""

func entry(delta):
	if textbox_entry_timer > 0:
		textbox_entry_timer = max(0, textbox_entry_timer - delta)
		var sc = clamp(textbox_entry_timer / textbox_entry_timer_max, 0, 1)
		label_node.modulate.a = 1 - sc

func _input(event: InputEvent):
	if is_instance_of(event, InputEventMouseButton):
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if label_node.text.length() == text.length() and label_node.text.length() > 0 and text.length() > 0:
				emit_signal("next")


func _process(delta):
	if text.length() > 0 and label_node.text.length() < text.length():
		if letter_timer_counter == 0:
			label_node.text = text.left(label_node.text.length() + 1)
			letter_timer_counter = letter_delay

		letter_timer_counter = max(0, letter_timer_counter - delta)
	else:
		letter_timer_counter = 0

	self.entry(delta)
