class_name Cafe extends Node

@onready var cafe_bottle_node = $Design/CafeBottle
@onready var cafe_node = $Design/CafeBottle/Extras
@onready var toppings_node = $Menu/ToppingsContainer/Toppings
@onready var sinkers_node = $Menu/SinkersContainer/Sinkers
@onready var base_node = $Menu/BaseContainer/Base
@onready var complete_button = $Menu/CompleteButtonContainer/Button
@onready var potion_slot = $Menu/PotionSlot

var bottle_state = "idle"
var bottle_jump_progress = 0
var bottle_shake_progress = 0
var bottle_cooldown = 0

var toggle_button_template = preload("res://scenes/ToggleButton.tscn")

func _ready():
	build_menu()
	build_drink()

	complete_button.pressed.connect(_on_complete_pressed)

func clear_menu():
	for child in toppings_node.get_children():
		child.queue_free()
	for child in sinkers_node.get_children():
		child.queue_free()
	for child in base_node.get_children():
		child.queue_free()

	

func clear_drink():
	for child in cafe_node.get_children():
		child.queue_free()

func build_complete_button():
	var button = Button.new()
	button.text = "Complete"
	button.rect_min_size = Vector2(100, 50)
	complete_button.add_child(button)

func build_menu():
	clear_menu()

	var extras = Resources.get_all_data(Resources.Configuration.CAFE) as Array[Dictionary]

	for extra in extras:
		var button = toggle_button_template.instantiate() as Button
		if not extra.has('icon') or not extra["icon"]:
			button.text = extra['name']
		else:
			var texture = button.get_node("TextureRect")
			texture.texture = load("res://assets/" + extra["icon"])
		
		var button_label = button.find_child("Title") as Label
		button_label.text = extra.name
		var button_desc_label = button.find_child("Description") as Label
		button_desc_label.text = ""

		button.pressed.connect(_on_extra_toggled.bind(extra))

		if extra['layer'] == 'toppings':
			button.button_pressed = (Data.saved_drink_data["toppings"] as Array[String]).has(extra['id'])
			toppings_node.add_child(button)
		elif extra['layer'] == 'sinkers':
			button.button_pressed = (Data.saved_drink_data["sinkers"] as Array[String]).has(extra['id'])
			sinkers_node.add_child(button)
		elif extra['layer'] == 'base':
			button.button_pressed = (Data.saved_drink_data["base"] as String) == extra['id']
			base_node.add_child(button)

			
	if Data.saved_potion and potion_slot:
		var potion_data = Resources.get_data(Resources.Configuration.RECIPES, func(d):
			return d.id == Data.saved_potion
		)
		var texture = load("res://" + potion_data.asset)
		var button_margin_cnt = potion_slot.get_node("MarginContainer") as MarginContainer
		button_margin_cnt.add_theme_constant_override("margin_left", 0)
		button_margin_cnt.add_theme_constant_override("margin_top", 0)
		button_margin_cnt.add_theme_constant_override("margin_right", 0)
		button_margin_cnt.add_theme_constant_override("margin_bottom", 0)
		var button_texture_rect = button_margin_cnt.get_node("TextureRect") as TextureRect
		button_texture_rect.texture = texture
		var button_label = potion_slot.find_child("Title") as Label
		button_label.text = potion_data.name
		var button_desc_label = potion_slot.find_child("Description") as Label
		button_desc_label.text = potion_data.description
		var tt = potion_slot.find_child("TooltipManager") as Tooltip
		tt.disable = false

	if Data.saved_potion == "" or Data.saved_potion == null or Data.saved_drink_data['base'] == "" or Data.saved_drink_data['base'] == null:
		complete_button.disabled = true

	if Data.saved_potion != "" and Data.saved_potion != null and Data.saved_drink_data['base'] != "" and Data.saved_drink_data['base'] != null:
		complete_button.disabled = false


func build_drink():
	clear_drink()

	var data = Data.saved_drink_data

	var cafe = Resources.get_all_data(Resources.Configuration.CAFE) as Array[Dictionary]

	for topping in data['toppings']:
		var extra = cafe.filter(func(v):
			return v['id'] == topping
		)[0]
		if extra != null:
			var sprite_node = Sprite2D.new()
			sprite_node.texture = load("res://assets/" + extra['sprite'])
			sprite_node.position = Vector2(
				extra['position']['x'],
				extra['position']['y']
			)
			sprite_node.z_index = 5
			cafe_node.add_child(sprite_node)

	for sinker in data['sinkers']:
		var extra = cafe.filter(func(v):
			return v['id'] == sinker
		)[0]
		if extra != null:
			var sprite_node = Sprite2D.new()
			sprite_node.texture = load("res://assets/" + extra['sprite'])
			sprite_node.position = Vector2(
				extra['position']['x'],
				extra['position']['y']
			)
			sprite_node.z_index = 1
			cafe_node.add_child(sprite_node)

	var filtered = cafe.filter(func(v):
		return v['id'] == data['base']
	)

	if filtered.size() > 0:
		var base = filtered[0]

		if base != null:
			var sprite_node = Sprite2D.new()
			sprite_node.texture = load("res://assets/" + base['sprite'])
			sprite_node.position = Vector2(
				base['position']['x'],
				base['position']['y']
			)
			sprite_node.z_index = 0
			cafe_node.add_child(sprite_node)

	if Data.saved_potion != "":
		var pot = Resources.get_data(Resources.Configuration.RECIPES, func(v):
			return v['id'] == Data.saved_potion
		)

		if pot != null:
			var sprite_node = Sprite2D.new()
			print("res://assets/" + pot['sprite'])
			sprite_node.texture = load("res://assets/" + pot['sprite'])
			sprite_node.position = Vector2(
				pot['position']['x'],
				pot['position']['y']
			)
			sprite_node.z_index = 1
			cafe_node.add_child(sprite_node)
			

func _on_extra_toggled(extra):
	Data.save_data(func(prev):
		if extra['layer'] == 'toppings':
			if not prev["drink_data"]["toppings"].has(extra['id']):
				(prev["drink_data"]["toppings"] as Array[String]).append(extra['id'])
			else:
				(prev["drink_data"]["toppings"] as Array[String]).erase(extra['id'])
		elif extra['layer'] == 'sinkers':
			if not prev["drink_data"]["sinkers"].has(extra['id']):
				(prev["drink_data"]["sinkers"] as Array[String]).append(extra['id'])
			else:
				(prev["drink_data"]["sinkers"] as Array[String]).erase(extra['id'])
		elif extra['layer'] == 'base':
			prev["drink_data"]["base"] = extra['id']

		return prev
	);

	build_menu()
	build_drink()


func _process(delta):
	if bottle_state == 'idle' and bottle_cooldown <= 0:
		var rand = randi() % 100
		if rand > 80:
			bottle_state = 'jump'
			cafe_bottle_node.position.y = 344

	if bottle_state == 'jump':
		bottle_jump_progress += delta * 10 
		cafe_bottle_node.position.y = lerpf(344., 304., bottle_jump_progress)
		if bottle_jump_progress >= 1:
			bottle_state = 'shake'

	if bottle_state == 'shake':
		bottle_shake_progress += delta
		cafe_bottle_node.rotation = sin(bottle_shake_progress * 40) * 0.2
		if bottle_shake_progress >= 1:
			bottle_state = 'return'
			bottle_jump_progress = 0

	if bottle_state == 'return':
		bottle_jump_progress += delta * 10 
		cafe_bottle_node.position.y = lerpf(304., 344., bottle_jump_progress)
		if bottle_jump_progress >= 1:
			bottle_state = 'idle'
			bottle_shake_progress = 0
			bottle_jump_progress = 0
			cafe_bottle_node.position.y = 344
			cafe_bottle_node.rotation = 0
			bottle_cooldown = 3

	if bottle_cooldown > 0 and bottle_state == 'idle':
		bottle_cooldown -= delta

	pass


func _on_complete_pressed():
	Data.sent_drink = true
	Navigation.change_scene(Global.Scene.COUNTER)
	Music.play_music(Music.SFX.Order)