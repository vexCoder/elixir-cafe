class_name TextboxArtsy extends Control

enum Anchor {
	TOP_LEFT = 0,
	TOP_RIGHT = 1,
	BOTTOM_LEFT = 2,
	BOTTOM_RIGHT = 3,
}

enum ArrowPos {
	LEFT = 0,
	RIGHT = 1,
	NONE = 2,
}

@onready var box_base = preload("res://scenes/TextboxBase.tscn")
@onready var text_node = $Text
@onready var name_node = $Name
@onready var message_container = $TextBox as TextureRect

signal choice_selected(choice: Dictionary)
signal next()

var letter_delay: float = 0.02
var letter_timer_counter: float = 0
var text = ""
var float_speed = 10
var float_y_max = 2
var float_dir = 1
var anchor_pos = Vector2.ZERO
var start_pos = Vector2.ZERO
var textbox_entry_timer = 0
var textbox_entry_timer_max = 0.25
var choices = []
var anchor_box_separation = 12
var extra_height = 0

func _ready():
	pass

func print_message(txt: String, pos: Vector2, targetName: String = '', anchor = Anchor.TOP_LEFT, arrow = ArrowPos.RIGHT, ch: = []) -> void:
	global_position = Vector2(pos.x, pos.y)
	anchor_pos = pos
	start_pos = pos
	text = txt
	letter_timer_counter = letter_delay
	textbox_entry_timer = textbox_entry_timer_max
	scale = Vector2(0.25, 0.25)
	choices = ch
	text_node.text = txt
	name_node.text = targetName

	# for i in range(choices.size()):
	# 	var choice_node = box_base.instantiate() as MarginContainer
	# 	var choice_label_node = choice_node.find_child("Label") as Label
	# 	var choice_label_container = choice_node.find_child("LabelContainer") as MarginContainer

	# 	choice_label_container.add_theme_constant_override("margin_left", 24)
	# 	choice_label_container.add_theme_constant_override("margin_right", 24)
	# 	choice_label_container.add_theme_constant_override("margin_top", 8)
	# 	choice_label_container.add_theme_constant_override("margin_bottom", 12)
		
	# 	choice_label_node.text = choices[i]['text']
	# 	choice_node.name = "ChoiceContainer " + str(i)
	# 	choices_container.add_child(choice_node)
	# 	choice_node.hide()
	# 	extra_height += choice_node.size.y - 24 - 12

	# extra_height += (choices.size() - 1) * anchor_box_separation

	# global_position.y = start_pos.y
	# anchor_pos.y = start_pos.y

	if arrow == ArrowPos.LEFT:
		message_container.flip_h = true
	elif arrow == ArrowPos.RIGHT:
		message_container.flip_h = false

	


func float(delta):
	var diff = global_position.y - anchor_pos.y

	if float_dir == 1 and diff > float_y_max:
		float_dir *= -1
	elif float_dir == -1 and diff < -float_y_max:
		float_dir *= -1

	global_position.y += float_speed * float_dir * delta

func entry(delta):
	if textbox_entry_timer > 0:
		textbox_entry_timer = max(0, textbox_entry_timer - delta)
		var sc = clamp(textbox_entry_timer / textbox_entry_timer_max, 0, 1)
		scale.x = 1 - sc
		scale.y = 1 - sc

func _input(event: InputEvent):
	if is_instance_of(event, InputEventMouseButton):
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if textbox_entry_timer == 0:
				if choices.size() > 0:
					pass;
					# var choice_children = choices_container.get_children()
					# var all_visible = choice_children.filter(func (v): return v.visible == true).size()
					# if all_visible:
					# 	for i in range(choices.size()):
					# 		var node = choice_children[i]
					# 		if node.get_global_rect().has_point(mouse_event.global_position):
					# 			var choice = choices[i]
					# 			emit_signal("choice_selected", choice)
					# 			break
					# 		pass
				else:
					var message_cnt = message_container.get_child(0)
					if message_cnt and is_instance_of(message_cnt, MarginContainer):
						var message_label = message_cnt.find_child("Label")		
						if message_label.text.length() == text.length():
							emit_signal("next")


# func _process(delta):
# 	# var choice_children = choices_container.get_children()
# 	# var all_visible = choice_children.filter(func (v): return v.visible == true).size()
# 	var message_cnt = message_container.get_child(0)
	
# 	if message_cnt and is_instance_of(message_cnt, MarginContainer):
# 		var message_label = message_cnt.find_child("Label")		
# 		if message_label and text.length() > 0 and message_label.text.length() < text.length():
# 			if letter_timer_counter == 0:
# 				message_label.text = text.left(message_label.text.length() + 1)
# 				letter_timer_counter = letter_delay

# 			letter_timer_counter = max(0, letter_timer_counter - delta)
# 		elif choices.size() > 0 and choice_children.size() == choices.size() and not all_visible:
# 			for node in choice_children:
# 				node.show()

# 			global_position.y = start_pos.y + extra_height
# 			anchor_pos.y = start_pos.y + extra_height
# 		else:
# 			letter_timer_counter = 0

# 		self.entry(delta)
# 		self.float(delta)
