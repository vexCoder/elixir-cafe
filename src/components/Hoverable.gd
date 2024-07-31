class_name Hoverable extends Node

@onready var target: Control = $".."

var state_hovered = false
var hovered_scale_max = 0.13
var hovered_scale_counter = Vector2.ZERO

func _ready():
	target.mouse_entered.connect(_on_mouse_entered)
	target.mouse_exited.connect(_on_mouse_exited)
	set_process_input(true)		

func _process(delta):
	if state_hovered:
		# Do something when hovered
		target.scale = Vector2.ONE + hovered_scale_counter

		if hovered_scale_counter.x < hovered_scale_max:
			hovered_scale_counter.x = min(hovered_scale_max, hovered_scale_counter.x + delta * 2)
			hovered_scale_counter.y = hovered_scale_counter.x
			target.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif hovered_scale_counter.x > 0 and not state_hovered:
		target.scale = Vector2.ONE + hovered_scale_counter
		hovered_scale_counter.x = max(0, hovered_scale_counter.x - delta * 2)
		hovered_scale_counter.y = hovered_scale_counter.x
		target.mouse_default_cursor_shape = Control.CURSOR_ARROW
					
func _on_mouse_entered():
	state_hovered = true

func _on_mouse_exited():
	state_hovered = false
