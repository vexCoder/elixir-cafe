class_name Textbox extends Control

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
@onready var message_container = $Container/MessageContainer
@onready var choices_container = $Container/ChoicesContainer
@onready var pointer = $Container/MessageContainer/PointerContainer
@onready var anchor_node = $Container

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
	anchor_node.add_theme_constant_override("separation", anchor_box_separation)
	pass

func print_message(txt: String, pos: Vector2, targetName: String = '', anchor = Anchor.TOP_LEFT, arrow = ArrowPos.RIGHT, ch: = []) -> void:
	global_position = pos
	anchor_pos = pos
	start_pos = pos
	text = txt
	anchor_node.layout_mode = 1
	anchor_node.anchors_preset = anchor
	letter_timer_counter = letter_delay
	textbox_entry_timer = textbox_entry_timer_max
	scale = Vector2(0, 0)
	choices = ch
	var message_node = box_base.instantiate() as MarginContainer
	message_node.name = "TextboxContainer"
	message_container.add_child(message_node)
	message_container.move_child(message_node, 0)

	for i in range(choices.size()):
		var choice_node = box_base.instantiate() as MarginContainer
		var choice_label_node = choice_node.find_child("Label") as Label
		var choice_label_container = choice_node.find_child("LabelContainer") as MarginContainer

		choice_label_container.add_theme_constant_override("margin_left", 24)
		choice_label_container.add_theme_constant_override("margin_right", 24)
		choice_label_container.add_theme_constant_override("margin_top", 8)
		choice_label_container.add_theme_constant_override("margin_bottom", 12)
		
		choice_label_node.text = choices[i]['text']
		choice_node.name = "ChoiceContainer " + str(i)
		choices_container.add_child(choice_node)
		choice_node.hide()
		extra_height += choice_node.size.y - 24 - 12

	if targetName.length() > 0:
		var name_node_padding_node = MarginContainer.new()
		var name_node_container = HBoxContainer.new()
		var name_node = box_base.instantiate() as MarginContainer
		var name_label_node = name_node.find_child("Label") as Label
		var name_label_container = name_node.find_child("LabelContainer") as MarginContainer

		name_label_container.add_theme_constant_override("margin_left", 24)
		name_label_container.add_theme_constant_override("margin_right", 24)
		name_label_container.add_theme_constant_override("margin_top", 8)
		name_label_container.add_theme_constant_override("margin_bottom", 12)

		name_node_padding_node.add_theme_constant_override("margin_left", 12)
		name_node_padding_node.add_theme_constant_override("margin_bottom", -24 )

		name_label_node.autowrap_mode = 0
		name_label_node.custom_minimum_size = Vector2(0, 0)
		
		name_label_node.text = targetName
		name_node.name = "NameContainer"
		name_node_container.add_child(name_node)
		name_node_padding_node.add_child(name_node_container)
		anchor_node.add_child(name_node_padding_node)
		anchor_node.move_child(name_node_padding_node, 0)
		name_node_padding_node.z_index = 100
		extra_height += name_node_container.size.y - 24 - 12 - 12

	extra_height += (choices.size() - 1) * anchor_box_separation

	global_position.y = start_pos.y
	anchor_pos.y = start_pos.y

	if arrow == ArrowPos.LEFT:
		var pointer_box = pointer.get_child(0) as HBoxContainer
		pointer_box.alignment = 0
		var pointer_texture = pointer_box.get_child(0) as TextureRect
		pointer_texture.flip_h = true
	elif arrow == ArrowPos.RIGHT:
		var pointer_box = pointer.get_child(0) as HBoxContainer
		pointer_box.alignment = 2
		var pointer_texture = pointer_box.get_child(0) as TextureRect
		pointer_texture.flip_h = false
	elif arrow == ArrowPos.NONE:
		var pointer_box = pointer.get_child(0) as HBoxContainer
		var pointer_texture = pointer_box.get_child(0) as TextureRect
		pointer.hide()
		pointer_box.hide()
		pointer_texture.hide()

	


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
					var choice_children = choices_container.get_children()
					var all_visible = choice_children.filter(func (v): return v.visible == true).size()
					if all_visible:
						for i in range(choices.size()):
							var node = choice_children[i]
							if node.get_global_rect().has_point(mouse_event.global_position):
								var choice = choices[i]
								emit_signal("choice_selected", choice)
								break
							pass
				else:
					var message_cnt = message_container.get_child(0)
					if message_cnt and is_instance_of(message_cnt, MarginContainer):
						var message_label = message_cnt.find_child("Label")		
						if message_label.text.length() == text.length():
							emit_signal("next")


func _process(delta):
	var choice_children = choices_container.get_children()
	var all_visible = choice_children.filter(func (v): return v.visible == true).size()
	var message_cnt = message_container.get_child(0)
	
	if message_cnt and is_instance_of(message_cnt, MarginContainer):
		var message_label = message_cnt.find_child("Label")		
		if message_label and text.length() > 0 and message_label.text.length() < text.length():
			if letter_timer_counter == 0:
				message_label.text = text.left(message_label.text.length() + 1)
				letter_timer_counter = letter_delay

			letter_timer_counter = max(0, letter_timer_counter - delta)
		elif choices.size() > 0 and choice_children.size() == choices.size() and not all_visible:
			for node in choice_children:
				node.show()

			global_position.y = start_pos.y + extra_height
			anchor_pos.y = start_pos.y + extra_height
		else:
			letter_timer_counter = 0

		self.entry(delta)
		self.float(delta)
