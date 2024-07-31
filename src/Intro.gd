class_name Intro extends Node2D

@onready var bg_1 = $"1" as Sprite2D
@onready var bg_2 = $"2" as Sprite2D
@onready var bg_3 = $"3" as Sprite2D
@onready var bg_4 = $"4" as Sprite2D

var current = 1
var next = 1
var progress = 0
var conversation_node: Conversation;

func _ready():
	bg_1.visible = true
	bg_2.visible = false
	bg_2.self_modulate.a = 0
	bg_3.visible = false
	bg_3.self_modulate.a = 0
	bg_4.visible = false
	bg_4.self_modulate.a = 0

	conversation_node = Conversation.new()
	add_child.call_deferred(conversation_node)
	conversation_node.name = "Conversation"
	conversation_node.on_dialogue.connect(_on_dialogue)

	conversation_node.start("90000", [
		{"id": "narrator", "offset": Vector2(0, 230), "letterbox": true}
	])

func _on_dialogue(id: String) -> void:
	if id == "90000" and next == 1:
		next = 1
	if id == "90002" and next == 1:
		next = 2
	if id == "90004" and next == 2:
		next = 3
	if id == "90005" and next == 3:
		next = 4

	if id == "90007":
		Navigation.change_scene(Global.Scene.COUNTER)
		Data.reset()

	progress = 0

func _process(delta):
	if current != next:
		progress += delta

		var bg_prev = get_node(str(current))
		var bg_next = get_node(str(next))

		bg_prev.visible = true
		bg_next.visible = true

		bg_prev.self_modulate.a = 1 - progress
		bg_next.self_modulate.a = progress
		
		if progress >= 1:
			progress = 1
			bg_prev.self_modulate.a = 0
			bg_next.self_modulate.a = 1
			current = next
			for i in range(4):
				if i != current - 1:
					var bg = get_node(str(i + 1))
					bg.hide()
					bg.self_modulate.a = 0
		