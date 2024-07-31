extends CanvasLayer

@export var start_progress: float = 1.0;

@onready var scenes: Dictionary = {
	Global.Scene.ALCHEMY: "res://scenes/Alchemy.tscn",
	Global.Scene.CAFE: "res://scenes/Cafe.tscn",
	Global.Scene.COUNTER: "res://scenes/Game.tscn",
	Global.Scene.GAMEOVER: "res://scenes/Outro.tscn",
	Global.Scene.INTRO: "res://scenes/Intro.tscn",
	Global.Scene.MENU: "res://scenes/Menu.tscn",
}

signal scene_changed
signal transition_done

var current_scene: Global.Scene = Global.Scene.MENU
var next_scene: Global.Scene = Global.Scene.MENU
var is_ready = true
var dir = 0

func change_scene(scene: Global.Scene):
	if not is_ready:
		return

	var mat = get_mat()

	if not mat:
		return

	dir = 1

	is_ready = false
	next_scene = scene

	await scene_changed

	get_tree().change_scene_to_file(scenes[next_scene])
	
	mat = get_mat()
	mat.set_shader_parameter("progress", 1.0)

	dir = -1

	await transition_done

	current_scene = next_scene
	
	is_ready = true

func get_mat():
	var node = $Transition
	return node.material as ShaderMaterial

func _process(delta):
	if dir == 1:
		var mat = get_mat()
		mat.set_shader_parameter("progress", clamp(mat.get_shader_parameter("progress") + delta, 0.0, 1.0))
		if mat.get_shader_parameter("progress") >= 1.0:
			emit_signal("scene_changed")
	elif dir == -1:
		var mat = get_mat()
		mat.set_shader_parameter("progress", clamp(mat.get_shader_parameter("progress") - delta, 0.0, 1.0))
		if mat.get_shader_parameter("progress") <= 0.0:
			emit_signal("transition_done")
	pass
