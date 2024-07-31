class_name Menu extends Node2D

@onready var new_gamec_node = $NewGameC as Node2D
@onready var continuec_node = $ContinueC as Node2D
@onready var new_game_node = $NewGameC/NewGame as Label
@onready var continue_node = $ContinueC/Continue as Label

var progress_ng = 0
var hovered_ng = 0
var progress_c = 0
var hovered_c = 0

func _ready():
	new_game_node.mouse_entered.connect(_on_new_game_hovered)
	new_game_node.mouse_exited.connect(_on_new_game_unhovered)

	new_game_node.gui_input.connect(_on_new_game_pressed)

	var check = false;

	if Data.npc_state == 0 and Data.npc_conversation == "" and Data.saved_potion == "" and Data.saved_drink_data["toppings"].size() == 0 and Data.saved_drink_data["sinkers"].size() == 0:
		check = true

	if not check:
		continue_node.gui_input.connect(_on_continue_pressed)
		continue_node.mouse_entered.connect(_on_continue_hovered)
		continue_node.mouse_exited.connect(_on_continue_unhovered)
	else:
		continue_node.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))

func _on_new_game_pressed(event: InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			Navigation.change_scene(Global.Scene.INTRO)
			Music.play_music(Music.SFX.Transition)

func _on_continue_pressed(event: InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			Navigation.change_scene(Global.Scene.COUNTER)
			Music.play_music(Music.SFX.Transition)

func _on_new_game_hovered():
	hovered_ng = 1

func _on_new_game_unhovered():
	hovered_ng = 0

func _on_continue_hovered():
	hovered_c = 1

func _on_continue_unhovered():
	hovered_c = 0


func process_hover(node, progress):
	var scale_lerp = lerpf(1, 1.1, progress)
	node.scale = Vector2(scale_lerp, scale_lerp)

func _process(delta):
	if hovered_ng == 1:
		progress_ng += delta * 10
	else:
		progress_ng -= delta * 10

	if hovered_c == 1:
		progress_c += delta * 10
	else:
		progress_c -= delta * 10

	process_hover(new_gamec_node, progress_ng)
	process_hover(continuec_node, progress_c)

	progress_ng = clamp(progress_ng, 0, 1)
	progress_c = clamp(progress_c, 0, 1)
