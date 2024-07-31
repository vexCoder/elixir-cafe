class_name Float extends Node

enum FloatDir {
	X,
	Y
}

@onready var target: Node2D = $".."

@export var float_dir: FloatDir = FloatDir.Y
@export var float_speed = 10
var float_max = 2
var float_dir_state = 1
var anchor_pos = Vector2.ZERO

func _ready():
	anchor_pos = target.global_position
	pass

func _process(delta):
	var start = target.global_position.y if float_dir == FloatDir.Y else target.global_position.x
	var end = anchor_pos.y if float_dir == FloatDir.Y else anchor_pos.x

	var diff = start - end

	if float_dir_state == 1 and diff > float_max:
		float_dir_state *= -1
	elif float_dir_state == -1 and diff < -float_max:
		float_dir_state *= -1

	if float_dir == FloatDir.Y:
		target.global_position.y += float_speed * float_dir_state * delta
	else:
		target.global_position.x += float_speed * float_dir_state * delta
