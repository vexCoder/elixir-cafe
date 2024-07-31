class_name AlchemyMenu extends Control

@onready var button_scene: PackedScene = preload("res://scenes/IngredientButton.tscn")


@onready var ingredient_container_cnt = $IngredientContainer
@onready var ingredient_container = $IngredientContainer/ScrollContainer/HFlowContainer
@onready var recipe_container_cnt = $RecipeContainer
@onready var recipe_container = $RecipeContainer/ScrollContainer/HFlowContainer
@onready var ingredient_btn = $HBoxContainer/MarginContainer/Button as Button
@onready var recipe_btn = $HBoxContainer/MarginContainer2/Button as Button
@onready var mix_btn = $MarginContainer2/Button as Button
@onready var active_ingredients_container = $ActiveIngredientsContainer
@onready var active_ingredients_panel = $ActiveIngredientsContainer/ScrollContainer/MarginContainer/HBoxContainer
@onready var followed_node = $"../Followed" as Node2D
@onready var navigate_btn = $"../CanvasLayer/NavigateCounterRight" as Control
@onready var color_rect = $"../Design/ColorRect" as ColorRect
@onready var narrator_scene = preload("res://scenes/Narration.tscn")
@onready var canvas_layer = $"../CanvasLayer" as CanvasLayer
@onready var potion_slot = $"PotionSlot" as Button
@onready var cafe_slot = $"CafeSlot" as Button

var ingredients = []
var recipes = []
var active = 0

var state_mix = 0
var mix_pan_value = 1
var active_ingredients = []
var MAX_INGREDIENTS = 5

var next_color: Color = Color(196.0 / 255., 67.0 / 255., 196.0 / 255., 255.0 / 255.)
var color_progress = 0
var mix_value = 0

func _ready():
	var data = Resources.get_all_data(Resources.Configuration.INGREDIENT)
	for ingredient in data:
		var button = button_scene.instantiate() as Button
		var texture = load("res://" + ingredient.asset)
		var button_texture_rect = button.get_node("TextureRect") as TextureRect
		button_texture_rect.texture = texture
		var button_label = button.find_child("Title") as Label
		button_label.text = ingredient.name
		var button_desc_label = button.find_child("Description") as Label
		button_desc_label.text = ingredient.description
		ingredient_container.add_child.call_deferred(button)
		button.gui_input.connect(_on_add_ingredient.bind(ingredient))

	for recipe in Data.saved_recipes:
		var recipe_data = Resources.get_data(Resources.Configuration.RECIPES, func(d):
			return d.id == recipe
		)

		if recipe_data:
			var button = button_scene.instantiate() as Button
			var texture = load("res://" + recipe_data.asset)
			var button_texture_rect = button.get_node("TextureRect") as TextureRect
			button_texture_rect.texture = texture
			var button_label = button.find_child("Title") as Label
			button_label.text = recipe_data.name
			var button_desc_label = button.find_child("Description") as Label
			var ingredients_names = recipe_data.combinations.map(func(c):
				var ingr = c.map(func(i):
					var ingredient = Resources.get_data(Resources.Configuration.INGREDIENT, func(d):
						return d.id == i
					)
					return "- " + ingredient.name
				)

				var name_ing = ''

				for i in range(ingr.size()):
					var ig = ingr[i]
					name_ing += "\n    " + ig 
				return name_ing
			)

			var all_names = ''
			for ing in range(ingredients_names.size()):
				var ingredient = ingredients_names[ing]
				all_names += ("\nor" if ing > 0 else "") + ingredient

			button_desc_label.text = recipe_data.description + all_names
			recipe_container.add_child.call_deferred(button)

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
		potion_slot.gui_input.connect(_on_potion_pressed)


	ingredient_btn.pressed.connect(_on_ingredient_pressed)
	recipe_btn.pressed.connect(_on_recipe_pressed)
	mix_btn.pressed.connect(_on_mix_pressed)
	Data.data_saved.connect(_on_data_saved)

	ingredient_container_cnt.show()
	recipe_container_cnt.hide()
	pass;

func _on_ingredient_pressed():
	if active == 0:
		return
	active = 0
	ingredient_container_cnt.show()
	recipe_container_cnt.hide()
	mix_btn.show()
	active_ingredients_container.show()
	pass;

func _on_recipe_pressed():
	if active == 1:
		return
	active = 1
	ingredient_container_cnt.hide()
	recipe_container_cnt.show()
	mix_btn.hide()
	active_ingredients_container.hide()
	pass;

func print_color(color: Color):
	return "Color: " + str(color.r8) + " " + str(color.g8) + " " + str(color.b8) + " " + str(color.a8)

func mix_color(base: Color, color: Color):
	var mix = Color()

	mix.a = 1. - (1. - color.a) * (1. - base.a)
	mix.r8 = (color.r8 + base.r8) / 2.
	mix.g8 = (color.g8 + base.g8) / 2.
	mix.b8 = (color.b8 + base.b8) / 2.

	return mix

func reset_color():
	var color: Color;
	for i in range(active_ingredients.size()):
		if not color:
			color = Color.from_string(active_ingredients[i].color, Color.BLACK)
		else:
			color = mix_color(color, Color.from_string(active_ingredients[i].color, Color.BLACK))
	if not color:
		color = Color(196.0 / 255., 67.0 / 255., 196.0 / 255., 255.0 / 255.)		
	
	next_color = color
	color_progress = 0

func _on_add_ingredient(event, ingredient):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if active_ingredients.size() >= MAX_INGREDIENTS:
				return

			active_ingredients.append(ingredient)
			var button = button_scene.instantiate() as Button
			var texture = load("res://" + ingredient.asset)
			var button_texture_rect = button.get_node("TextureRect") as TextureRect
			button_texture_rect.texture = texture
			var button_label = button.find_child("Title") as Label
			button_label.text = ingredient.name
			var button_desc_label = button.find_child("Description") as Label
			button_desc_label.text = ingredient.description
			active_ingredients_panel.add_child(button)
			button.gui_input.connect(_on_remove_ingredient.bind(button))

			reset_color()



func _on_remove_ingredient(event, btn):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var children = active_ingredients_panel.get_children()
			var idx = btn.get_index()

			active_ingredients.remove_at(idx)
			children[idx].queue_free()

			reset_color()

					
	pass;

func _on_mix_pressed():
	if active_ingredients.size() < 2:
		return

	var recipes_data = Resources.get_all_data(Resources.Configuration.RECIPES)

	var active_dict = {}

	for ingredient in active_ingredients:
		if not active_dict.has(ingredient.id):
			active_dict[ingredient.id] = 1
		else:
			active_dict[ingredient.id] += 1

	var recipe_found = null

	for recipe in recipes_data:
		var combinations = recipe.combinations

		for combination in combinations:
			var dict = {}
			var found = true

			for c_ing in combination:
				if not dict.has(c_ing):
					dict[c_ing] = 1
				else:
					dict[c_ing] += 1

			for key in dict.keys():
				if not active_dict.has(key) or active_dict[key] != dict[key]:
					found = false

			for key in active_dict.keys():
				if not dict.has(key) or active_dict[key] != dict[key]:
					found = false

			if found:
				recipe_found = recipe
				break


					
	if recipe_found:
		print("Found recipe: ", recipe_found.name)
		Data.save_data(func(data):
			if not data['recipes'].has(recipe_found.id):
				data["recipes"].append(recipe_found.id)

			data['potion'] = recipe_found.id
			return data
		)
		active_ingredients = []
		var tb = narrator_scene.instantiate() as Narration
		canvas_layer.add_child(tb)
		tb.print_message("Found recipe: " + recipe_found.name)
		tb.next.connect(func():
			canvas_layer.remove_child(tb)
		)
		Music.play_music(Music.SFX.Brew)
		var children = active_ingredients_panel.get_children()
		for child in children:
			child.queue_free()
	else:
		print("No recipe found")
		active_ingredients = []
		var tb = narrator_scene.instantiate() as Narration
		canvas_layer.add_child(tb)
		tb.print_message("Failed mixing")
		tb.next.connect(func():
			canvas_layer.remove_child(tb)
		)
		var children = active_ingredients_panel.get_children()
		for child in children:
			child.queue_free()

func _on_data_saved():
	print("Data saved")
	var children = recipe_container.get_children()

	for child in children:
		child.queue_free()

	for recipe in Data.saved_recipes:
		var recipe_data = Resources.get_data(Resources.Configuration.RECIPES, func(d):
			return d.id == recipe
		)

		if recipe_data:
			var button = button_scene.instantiate() as Button
			var texture = load("res://" + recipe_data.asset)
			var button_texture_rect = button.get_node("TextureRect") as TextureRect
			button_texture_rect.texture = texture
			var button_label = button.find_child("Title") as Label
			button_label.text = recipe_data.name
			var button_desc_label = button.find_child("Description") as Label
			var ingredients_names = recipe_data.combinations.map(func(c):
				var ingr = c.map(func(i):
					var ingredient = Resources.get_data(Resources.Configuration.INGREDIENT, func(d):
						return d.id == i
					)
					return "- " + ingredient.name
				)

				var name_ing = ''

				for i in range(ingr.size()):
					var ig = ingr[i]
					name_ing += "\n    " + ig 
				return name_ing
			)

			var all_names = ''
			for ing in range(ingredients_names.size()):
				var ingredient = ingredients_names[ing]
				all_names += ("\nor" if ing > 0 else "") + ingredient

			button_desc_label.text = recipe_data.description + all_names
			recipe_container.add_child.call_deferred(button)

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
		potion_slot.gui_input.connect(_on_potion_pressed)

	pass;

func _on_potion_pressed(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var texture = load("res://assets/potion.png")
			var button_margin_cnt = potion_slot.get_node("MarginContainer") as MarginContainer
			button_margin_cnt.add_theme_constant_override("margin_left", 16)
			button_margin_cnt.add_theme_constant_override("margin_top", 16)
			button_margin_cnt.add_theme_constant_override("margin_right", 16)
			button_margin_cnt.add_theme_constant_override("margin_bottom", 16)
			var button_texture_rect = button_margin_cnt.get_node("TextureRect") as TextureRect
			button_texture_rect.texture = texture
			var tt = potion_slot.find_child("TooltipManager") as Tooltip
			tt.disable = true
			Data.save_data(func(data):
				data['potion'] = ''
				return data
			)
	pass;

func _process(delta):
	if mix_pan_value < 1:
		if state_mix == 1:
			followed_node.position.x = lerpf(followed_node.position.x, 968, mix_pan_value)
		elif state_mix == 0:
			followed_node.position.x = lerpf(followed_node.position.x, 568, mix_pan_value)
		
		mix_pan_value += delta / 2

	if color_progress < 1:
		var mat = color_rect.material as ShaderMaterial
		var color = mat.get_shader_parameter("tone_color")
		if color != next_color:
			color = color.lerp(next_color, color_progress)
			mat.set_shader_parameter("tone_color", color)
			color_progress += delta / 2
	pass;
