class_name Conversation extends Node

@onready var textbox_scene = preload("res://scenes/Textbox.tscn")
@onready var textbox2_scene = preload("res://scenes/TextboxtArtsy.tscn")
@onready var narrator_scene = preload("res://scenes/Narration.tscn")
@onready var letterbox_scene = preload("res://scenes/Letterbox.tscn")
@onready var canvas_layer = $"../CanvasLayer"

var dialogue_entry_id: String = ""
var active_dialogue: Array[Dictionary] = [];
var participants: Array[Dictionary] = [];

signal on_dialogue(String)

func start(id: String, prt: Array[Dictionary]) -> void:
	Logger.i("Conversation started: " + id)
	
	dialogue_entry_id = id
	var dialogue = Resources.get_data(Resources.Configuration.DIALOGUE, func (v): return v["id"] == dialogue_entry_id)

	if dialogue == null:
		Logger.e("Conversation not found: " + dialogue_entry_id)
		return

	participants = prt
	active_dialogue.append(dialogue)
	on_dialogue.emit(id)

	pass

func clear():
	for i in range(active_dialogue.size()):
		if active_dialogue[i].has("textbox") and canvas_layer != null:
			canvas_layer.remove_child(active_dialogue[i].textbox)
			active_dialogue[i].textbox = null
			pass

		pass

	active_dialogue.clear()
	

# func _input(event):
# 	if Input.is_action_just_pressed("ui_accept"):
# 		var last = active_dialogue.pop_back()

# 		if last and last.has("next"):
# 			var next = Resources.get_data(Resources.Configuration.DIALOGUE, func (v): return v["id"] == last.next)
# 			if next:
# 				active_dialogue.append(next)
# 			else:
# 				Logger.e("Next dialogue not found: " + last.next)

# 		pass

func _process(_delta):

	if active_dialogue.size() > 0:
		for i in range(active_dialogue.size()):
			var dialogue = active_dialogue[i]
			var target = dialogue['target']
			var participant = participants.filter(func (v): return v['id'] == target)[0]
			
			if not participant:
				Logger.e("Participant not found: " + target)
				return
				
			var textbox = null if not dialogue.has("textbox") else active_dialogue[i].textbox
			var root = get_parent()
			var is_narrating = participant.has('narration') and participant.narration
			var is_letterbox = participant.has('letterbox') and participant.letterbox
			
			if not is_narrating and not is_letterbox and root:
				var children = root.get_children() as Array[Character]
				for child in children:
					if is_instance_of(child, Character) and child.char_id == target:
						var target_pos = child.global_position

						if not textbox:
							var tb = textbox_scene.instantiate() as Textbox
							tb.name = "Textbox " + str(i)
							var pos = target_pos + participant['offset']
							var anchor = Textbox.Anchor.BOTTOM_LEFT if target == "player" else Textbox.Anchor.BOTTOM_RIGHT
							canvas_layer.add_child(tb)
							var is_pos_left = pos.x < child.global_position.x
							var arrow = Textbox.ArrowPos.RIGHT if is_pos_left else Textbox.ArrowPos.LEFT
							var textbox_name = participant['name'] if participant.has("name") else ""
							if participant.has("hide_pointer") and participant.hide_pointer:
								arrow = Textbox.ArrowPos.NONE

							tb.print_message(
								dialogue['text'], 
								pos, 
								textbox_name,
								anchor,
								arrow,
								dialogue['responses'] if dialogue.has("responses") else []
							)
							active_dialogue[i].textbox = tb
							active_dialogue[i].textbox_name = tb.name
							tb.choice_selected.connect(_on_choice_selected)
							tb.next.connect(_on_next)

						else:
							active_dialogue[i].textbox.global_position = target_pos + participant['offset']
			elif is_narrating:
				if not textbox:
					var tb = narrator_scene.instantiate() as Narration
					tb.name = "Textbox " + str(i)
					canvas_layer.add_child(tb)
					tb.print_message(
						dialogue['text']
					)
					active_dialogue[i].textbox = tb
					active_dialogue[i].textbox_name = tb.name
					tb.choice_selected.connect(_on_choice_selected)
					tb.next.connect(_on_next)
			elif is_letterbox:
				if not textbox:
					var tb = letterbox_scene.instantiate() as Letterbox
					tb.name = "Textbox " + str(i)
					canvas_layer.add_child(tb)
					tb.print_message(
						dialogue['text'],
						participant['offset']
					)
					active_dialogue[i].textbox = tb
					active_dialogue[i].textbox_name = tb.name
					tb.choice_selected.connect(_on_choice_selected)
					tb.next.connect(_on_next)

			pass


func _on_choice_selected(choice: Dictionary) -> void:
	Logger.i("Choice selected: " + choice['text'])
	var last = active_dialogue[active_dialogue.size() - 1]
	if choice.has("next"):
		var next = Resources.get_data(Resources.Configuration.DIALOGUE, func (v): return v["id"] == choice.next)
		if next:
			var prt_data = participants.filter(func (v): return v['id'] == next['target'])[0]
			next['offset'] = prt_data['offset']
			canvas_layer.remove_child(last.textbox)
			active_dialogue.append(next)
			on_dialogue.emit(next['id'])
			Music.play_music(Music.SFX.Dialogue)

		pass;
	
	Logger.e("Next dialogue not found")
	# canvas_layer.remove_child(last.textbox)

	pass;

func _on_next() -> void:
	Logger.i("Next dialogue")
	var last = active_dialogue[active_dialogue.size() - 1]
	if last and last.has("next") and last.next:
		var next = Resources.get_data(Resources.Configuration.DIALOGUE, func (v): return v["id"] == last.next)
		if next:
			var prt_data = participants.filter(func (v): return v['id'] == next['target'])[0]
			next['offset'] = prt_data['offset']
			active_dialogue.append(next)
			canvas_layer.remove_child(last.textbox)
			on_dialogue.emit(next['id'])
			Music.play_music(Music.SFX.Dialogue)
		
		pass;

	Logger.e("Next dialogue not found")
	# canvas_layer.remove_child(last.textbox)
	
	pass;
