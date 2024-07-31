class_name Draggable extends Node

@onready var target: Node2D = $".."
@onready var collision_node: CollisionShape2D = $"../CollisionShape2D"

var state_pickup = false

func _ready():
	set_process_input(true)
	

func _input(event: InputEvent):
	if is_instance_valid(target):
		if event is InputEventMouseButton:
			var mouse_event = event as InputEventMouseButton
			if mouse_event.button_index == MOUSE_BUTTON_LEFT:
				var shape = collision_node.shape as RectangleShape2D
				var origin = target.transform.origin - shape.size / 2
				var rect = Rect2(origin, shape.size)
				if mouse_event.pressed and rect.has_point(mouse_event.global_position):
					state_pickup = true
				elif state_pickup:
					state_pickup = false

		if event is InputEventMouseMotion and state_pickup:
			target.global_position = get_viewport().get_mouse_position()
					