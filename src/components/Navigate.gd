class_name Navigate extends Control

@onready var target: Control = $".."

@export var to_nav: Global.Scene = Global.Scene.COUNTER

func _ready():
	target.gui_input.connect(_on_gui_input)
	pass

func _on_gui_input(event: InputEvent):
	if is_instance_valid(event) and event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			Navigation.change_scene(to_nav)
	pass
	
