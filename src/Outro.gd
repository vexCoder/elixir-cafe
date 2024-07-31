class_name Outro extends Node2D

@onready var narrator_scene = preload("res://scenes/Narration.tscn")
@onready var letterbox_scene = preload("res://scenes/Letterbox.tscn")
@onready var canvas_layer = $CanvasLayer
@onready var mc_node = $Heroes/MC
@onready var apollo_node = $Heroes/Apollo
@onready var buttercup_node = $Heroes/Buttercup
@onready var carsen_node = $Heroes/Carsen
@onready var vel_node = $Heroes/Vel
@onready var westley_node = $Heroes/Westley
@onready var end_win_node = $Win
@onready var end_lose_node = $GameOver

@onready var heroes = [
	westley_node,
	carsen_node,
	apollo_node,
	buttercup_node,
	vel_node,
]

@onready var heroes_key = [
	"npc_westley",
	"npc_carsen",
	"npc_apollo",
	"npc_buttercup",
	"npc_vel",
]

var killed = []

var narrator = null
var letterbox = null
var state = 0
var hero_state = 0

var hero_prog = 0
var hero_current = 'npc_westley'

var end_screen_prog = 0

var mc_prog = 0;
var diff_scale = 0.5 - 0.376

func check_drink(customer_data: Dictionary, submitted_data: Dictionary):
	var check = true;

	if customer_data['correct_drink'] and len(customer_data['correct_drink']) > 0:
		var extras = []
		extras.append_array(submitted_data['toppings'])
		extras.append_array(submitted_data['sinkers'])
		extras.append(submitted_data['base'])
		for drink in customer_data['correct_drink']:
			if not extras.has(drink):
				check = false
				break

	if customer_data['correct_potion'] and len(customer_data['correct_potion']) > 0:
		check = check and customer_data['correct_potion'].has(submitted_data['potion'])

	return check

func _ready():
	narrator = narrator_scene.instantiate() as Narration
	narrator.name = "Narrator"
	letterbox = letterbox_scene.instantiate() as Letterbox
	letterbox.name = "Letterbox"
	
	narrator.hide()
	letterbox.hide()

	letterbox.next.connect(_letterbox_next.bind(letterbox))
	narrator.next.connect(_letterbox_next.bind(narrator))

	canvas_layer.add_child(narrator)
	canvas_layer.add_child(letterbox)

	var keys = (Data.submitted_drink as Dictionary).keys()

	for v in keys:
		var customer_data = Resources.get_data(Resources.Configuration.CUSTOMER, func (c):
			return c['key'] == v
		)

		if not customer_data:
			continue

		var check = check_drink(customer_data, Data.submitted_drink[v])

		var ndata = Data.submitted_drink[v]
		ndata["key"] = v

		if check:
			killed.append(ndata)

	if killed.size() > 3:
		Music.play_theme("menu.mp3")
	else:
		Music.play_theme("i_am_sad.mp3")

	mc_node.show()
	mc_node.self_modulate.a = 0
	# mc_node.scale = Vector2(0.376, 0.376)
	mc_node.scale = Vector2(0.5, 0.5)

	for hero in heroes:
		hero.show()
		hero.modulate.a = 0
		hero.scale = Vector2(0.5, 0.5)

		var alive = hero.get_node("1")

		alive.show()
		
	handle_state()

func _letterbox_next(lb):
	if state == 1:
		state = 4
	if state == 3:
		state = 4
	if state == 5:
		Navigation.change_scene(Global.Scene.MENU)
		Data.reset()

	lb.erase_message()
	
func handle_state():
	var kill_count = killed.size()

	if state == 1:
		if kill_count == 0:
			letterbox.show()
			letterbox.print_message("All the heroes are alive", Vector2(0, 230))
		if kill_count >= 1:
			state = 2
			hero_current = heroes_key[0]
			hero_prog = 0

	if state == 3:
		letterbox.show()
		letterbox.print_message(str(kill_count) + " out of 5 heroes have fallen, unable to take justice on this land! It is believed that\nthe followers of the Crowverlord are the suspects but there is no evidence to be presented.", Vector2(0, 230))

	if state == 5:
		var is_win = killed.size() > 3

		narrator.show()
		if is_win:
			narrator.print_message("Congratulations! You have successfully halted the heroes’ journey. The members are all\ncelebrating and hailing you as the chosen one who protected your dark lord! The world shall\nnow be swept into an era of shadows underneath your rule.")
		else:
			narrator.print_message("Oh no! Despite your best efforts, the heroes have set on their quest, banding together to strike\ndown the Crowverlord! You failed in your duty and the organization you’ve grown to live and love\nhas fallen into the shadows.")
		

func _process(delta):
	if state == 0 and mc_node:
		if hero_state == 0:
			mc_prog += delta

			mc_node.self_modulate.a = mc_prog
			var scale_lerp = lerpf(0.4, 0.376, mc_prog)
			mc_node.scale = Vector2(scale_lerp, scale_lerp)

			if mc_prog >= 1:
				hero_state = 1
				mc_prog = 0
		if hero_state == 1:
			mc_prog += delta

			for hero in heroes:
				hero.modulate.a = mc_prog
				var scale_lerp = lerpf(0.4, 0.376, mc_prog)
				hero.scale = Vector2(scale_lerp, scale_lerp)

			if mc_prog >= 1:
				state = 1
				mc_prog = 0
				handle_state()

	if state == 2:
		var i = heroes_key.find(hero_current)
		var hero = heroes[i]
		var is_killed = killed.filter(func(v):
			return v['key'] == heroes_key[i]
		).size() > 0

		var kill_node = hero.get_node("2")
		var alive_node = hero.get_node("1")

		if is_killed:
			kill_node.show()
			hero_prog += delta * 2

			var scale_lerp = lerpf(1.1, 1, hero_prog)
			var inv_scale_lerp = lerpf(1, 0.9, hero_prog)

			alive_node.self_modulate.a = 1 - hero_prog
			alive_node.scale = Vector2(inv_scale_lerp, inv_scale_lerp)
			kill_node.self_modulate.a = hero_prog
			kill_node.scale = Vector2(scale_lerp, scale_lerp)
		else:
			kill_node.hide()
			alive_node.show()
			hero_prog = 1

		if hero_prog >= 1:
			if is_killed:
				alive_node.hide()
			
			hero_prog = 0
			var idx = i + 1
			if idx >= heroes.size():
				state = 3
				handle_state()
			else:
				hero_current = heroes_key[idx]
		

	if state == 4:
		end_screen_prog += delta

		var is_win = killed.size() > 3

		if is_win:
			end_win_node.show()
			end_lose_node.hide()

			end_win_node.self_modulate.a = end_screen_prog
		else:
			end_win_node.hide()
			end_lose_node.show()

			end_lose_node.self_modulate.a = end_screen_prog

		if end_screen_prog >= 1:
			state = 5
			handle_state()


