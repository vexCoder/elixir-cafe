class_name Game extends Node

@onready var player_scene = preload("res://scenes/Player.tscn")
@onready var customer_scene = preload("res://scenes/Customer.tscn")
@onready var retry = $CanvasLayer/Retry
@onready var navigate_alchemy = $CanvasLayer/NavigateAlchemy
@onready var navigate_cafe = $CanvasLayer/NavigateCafe

var npc_node: Character;
var conversation_node: Conversation;

var npc_out_delay = 3
var npc_entry_prog = 0;
var npc_entry_hop_prog = 0;
var start_pos = 1800
var end_pos = 888
var base_y = -130

func _ready():
	Logger.i("Game initialized")

	var player = player_scene.instantiate() as Character
	player.transform.origin = Vector2(286, 402)
	player.z_index = 1
	add_child(player)

	var npc = customer_scene.instantiate() as Character
	npc.char_id = Data.current_customer
	npc.transform.origin = Vector2(1400, 370)
	npc.z_index = -1
	npc.get_node("Sprite2D").texture = Asset.load(Data.current_customer + ".png")
	npc.get_node("Open").texture = Asset.load(Data.current_customer + ".png")
	npc.get_node("Open").hide()
	add_child.call_deferred(npc)
	npc_node = npc

	conversation_node = Conversation.new()
	add_child.call_deferred(conversation_node)
	conversation_node.name = "Conversation"
	conversation_node.on_dialogue.connect(_on_dialogue)

	Data.data_saved.connect(_data_saved)
	retry.gui_input.connect(_retry_conversation)

	if Data.npc_conversation != "" and (Data.npc_state == 1 or Data.npc_state == 2):
		var customer_data = Resources.get_data(Resources.Configuration.CUSTOMER, func (v):
			return v["key"] == Data.current_customer
		)

		conversation_node.clear()
		conversation_node.start(Data.npc_conversation, [
			{"id": "player", "offset": Vector2(125, base_y), "name": "MC"},
			{"id": Data.current_customer, "offset": Vector2(-125, base_y), "name": customer_data.name},
			{"id": "narrator", "offset": Vector2(0, 0), "narration": true}
		])

		npc.transform.origin = Vector2(888, 370)

	
	if Data.sent_drink and Data.npc_state == 2:
		Data.save_data(func(prev):
			prev["npc_state"] = 3
			return prev
		)

		var customer_data = Resources.get_data(Resources.Configuration.CUSTOMER, func (v):
			return v["key"] == Data.current_customer
		)

		var dialogue_entries = Resources.get_all_data(Resources.Configuration.DIALOGUE).filter(func(v):
			return v["target"] == customer_data.key and v.has('outro') and v["outro"] == true
		)

		# var entries = {
		# 	false: dialogue_entries.filter(func(v):
		# 	return v["correct"] == false
		# 	)[0],
		# 	true: dialogue_entries.filter(func(v):
		# 	return v["correct"] == true
		# 	)[0]
		# }
		
		# var check = check_drink(customer_data)
		var entry = dialogue_entries[0];

		conversation_node.clear()
		conversation_node.start(entry['id'], [
			{"id": "player", "offset": Vector2(125, base_y), "name": "MC"},
			{"id": Data.current_customer, "offset": Vector2(-125, base_y), "name": customer_data.name},
			{"id": "narrator", "offset": Vector2(0, 0), "narration": true}
		])

		npc_out_delay = 3
		npc_entry_prog = 0
		npc_entry_hop_prog = 0

	disable_navigation()
	Logger.i("Game started")

func check_drink(customer_data: Dictionary):
	var check = true;
	if customer_data['correct_drink'] and len(customer_data['correct_drink']) > 0:
		var extras = []
		extras.append_array(Data.saved_drink_data['toppings'])
		extras.append_array(Data.saved_drink_data['sinkers'])
		extras.append(Data.saved_drink_data['base'])
		for drink in customer_data['correct_drink']:
			if not extras.has(drink):
				check = false
				break

	if customer_data['correct_potion'] and len(customer_data['correct_potion']) > 0:
		check = check and customer_data['correct_potion'].has(Data.saved_potion)

	return check

func _on_dialogue(id: String):
	Data.save_data(func(prev):
		prev["npc_conversation"] = id
		return prev
	)

	var speech = Resources.get_data(Resources.Configuration.DIALOGUE, func (v):
		return v["id"] == id
	)

	if speech.has("final") and speech['final'] == true:
		Data.save_data(func(prev):
			prev["npc_state"] = 2
			return prev
		)

func disable_navigation():
	if Data.npc_state == 2:
		navigate_alchemy.show()
		navigate_cafe.show()
		retry.show()
	else:
		navigate_alchemy.hide()
		navigate_cafe.hide()
		retry.hide()

func _data_saved():
	disable_navigation()

	if Data.npc_state == 4 and Data.customers_left.size() > 0:
		npc_node.get_node("Sprite2D").texture = Asset.load(Data.current_customer + ".png")
		(npc_node.get_node("Sprite2D") as Sprite2D).flip_h = false
		npc_node.transform.origin = Vector2(1400, 370)
		Data.save_data(func(prev):
			prev["npc_state"] = 0
			return prev
		)
		npc_entry_hop_prog = 0
		npc_entry_prog = 0
		npc_node.char_id = Data.current_customer
		conversation_node.clear()

	if Data.customers_left.size() == 0:
		Navigation.change_scene(Global.Scene.GAMEOVER)
		pass

func _retry_conversation(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			npc_entry_prog = 0
			npc_entry_hop_prog = 0

			var customer_data = Resources.get_data(Resources.Configuration.CUSTOMER, func (v):
				return v["key"] == Data.current_customer
			)

			var entry = customer_data.entry_conversation
			
			Data.save_data(func(prev):
				prev["npc_state"] = 1
				prev["npc_conversation"] = entry
				return prev
			)

			conversation_node.clear()
			conversation_node.start(entry, [
				{"id": "player", "offset": Vector2(125, base_y), "name": "MC"},
				{"id": Data.current_customer, "offset": Vector2(-125, base_y), "name": customer_data.name},
				{"id": "narrator", "offset": Vector2(0, 0), "narration": true}
			])
	
		

func _process(delta):
	if Data.npc_state == 0:
		npc_node.transform.origin.x = lerpf(start_pos, end_pos, npc_entry_prog)
		npc_node.transform.origin.y = 370 + sin(npc_entry_hop_prog * PI) * 8

		if npc_entry_prog < 1:
			npc_entry_prog += delta
			npc_entry_hop_prog += delta * 10
		else:
			Data.save_data(func(prev):
				prev["npc_state"] = 1
				return prev
			)

			npc_entry_prog = 0
			npc_entry_hop_prog = 0

			var customer_data = Resources.get_data(Resources.Configuration.CUSTOMER, func (v):
				return v["key"] == Data.current_customer
			)
			var entry = customer_data.entry_conversation

			conversation_node.clear()
			conversation_node.start(entry, [
				{"id": "player", "offset": Vector2(125, base_y), "name": "MC"},
				{"id": Data.current_customer, "offset": Vector2(-125, base_y), "name": customer_data.name},
				{"id": "narrator", "offset": Vector2(0, 0), "narration": true}
			])


	if Data.npc_state == 3:
		npc_out_delay -= delta

		if npc_out_delay <= 0:
			npc_node.transform.origin.x = lerpf(end_pos, start_pos, npc_entry_prog)
			npc_node.transform.origin.y = 370 + sin(npc_entry_hop_prog * PI) * 8
			(npc_node.get_node("Sprite2D") as Sprite2D).flip_h = true

			if npc_entry_prog < 1:
				npc_entry_prog += delta
				npc_entry_hop_prog += delta * 10
			else:
				Data.sent_drink = false
				Data.save_data(func(prev):
					prev["npc_state"] = 4
					prev["npc_conversation"] = ""
					prev["submitted_drink"][Data.current_customer] = {
						'base': Data.saved_drink_data['base'],
						'toppings': Data.saved_drink_data['toppings'],
						'sinkers': Data.saved_drink_data['sinkers'],
						'potion': Data.saved_potion
					}
					prev["customers_left"].erase(Data.current_customer)
					if prev["customers_left"].size() > 0:
						prev["customer"] = prev["customers_left"][0]
					else:
						prev["customer"] = ""
					prev["potion"] = ""
					prev["drink_data"] = {
						"toppings": [],
						"sinkers": [],
						"base": ""
					}

					print(prev)

					return prev
				)


