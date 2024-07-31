extends Node

@onready var music: AudioStreamPlayer = $Music
@onready var sound: AudioStreamPlayer = $Sound

var current_music = null

enum SFX {
	Transition,
	Order,
	Brew,
	Dialogue
}

var sfx_map = [
	"res://assets/transition from cutscene to gameplay.wav",
	"res://assets/order up.wav",
	'res://assets/brewing potion.mp3',
	'res://assets/continue dialogue.mp3'
]

var map = {
	Global.Scene.MENU: "res://assets/menu.mp3",
	Global.Scene.INTRO: "res://assets/menu.mp3",
	Global.Scene.COUNTER: "res://assets/game.mp3",
	Global.Scene.ALCHEMY: "res://assets/game.mp3",
	Global.Scene.CAFE: "res://assets/game.mp3"
}

func _ready():
	Navigation.transition_done.connect(_on_transition_done)
	_on_transition_done()

func _on_transition_done():
	if map.has(Navigation.current_scene):
		var music_file = map[Navigation.current_scene]

		if music_file and current_music != music_file:
			current_music = music_file
			music.stream = load(music_file)
			music.play()

func play_music(sfx: SFX):
	var music_file = sfx_map[sfx]

	if music_file:
		sound.stream = load(music_file)
		sound.play()

func play_theme(file: String):
	music.stream = load("res://assets/" + file)
	music.play()