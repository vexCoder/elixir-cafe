class_name Tooltip extends Node

@onready var parent = $"..";
@onready var tooltip = $"../Tooltip";

@export var disable = false

func _ready():
	tooltip.hide()
	if parent.has_signal("mouse_entered"):
		parent.mouse_entered.connect(_on_mouse_entered)
	if parent.has_signal("mouse_exited"):
		parent.mouse_exited.connect(_on_mouse_exited)
	if parent.has_signal("gui_input"):
		parent.gui_input.connect(_gui_input)

func _on_mouse_entered():
	if disable:
		tooltip.hide()
		return

	tooltip.show()

func _on_mouse_exited():
	if disable:
		tooltip.hide()
		return

	tooltip.hide()

func _gui_input(event):
	if event is InputEventMouseMotion and not disable:
		var mouse_pos = get_viewport().get_mouse_position()
		tooltip.position = Vector2(0, -70) + mouse_pos
		var parent_rect  = parent.get_viewport_rect()
		tooltip.position = Vector2(
			clamp(tooltip.position.x, parent_rect.position.x, parent_rect.position.x + parent_rect.size.x - tooltip.size.x),
			clamp(tooltip.position.y, parent_rect.position.y,  parent_rect.position.y + parent_rect.size.y - tooltip.size.y)
		)
	
	if disable:
		tooltip.hide()
		return
		


