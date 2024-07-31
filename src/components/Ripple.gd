extends Node2D

@onready var line: Line2D = $Line2D

var queue: Array[Vector2] = []

func _ready():
	set_process(true)
	pass

func follow_mouse():
	global_position = get_viewport().get_mouse_position()
	var distance_from_center = global_position.distance_to(Vector2(960, 384))
	if distance_from_center > 150:
		var dir = (global_position - Vector2(960, 384)).normalized()
		global_position = Vector2(
			960 + dir.x * 150,
			384 + dir.y * 150
		)

func _process(_delta):
	follow_mouse()
	pass