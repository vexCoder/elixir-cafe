class_name Terminal extends Control

@onready var scroll = $Panel/ScrollContainer as ScrollContainer
@onready var vbox = $Panel/ScrollContainer/VBoxContainer as VBoxContainer
@onready var panel = $Panel as Panel

var max_scroll_length = 0 
var scroll_at_bottom = false

func _ready():
	var dim = get_viewport_rect().size
	scroll.size.x = dim.x
	scroll.size.y = dim.y / 2
	panel.size.x = dim.x
	panel.size.y = dim.y / 2
	Logger.get_logs().map(push_log)
	Logger.log_updated.connect(_on_log_updated)
	var scrollbar = scroll.get_v_scroll_bar()
	scrollbar.changed.connect(handle_scrollbar_changed)
	panel.hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_F1:
				if panel.visible:
					panel.hide()
					mouse_filter = Control.MOUSE_FILTER_IGNORE
				else:
					panel.show() 
					mouse_filter = Control.MOUSE_FILTER_STOP

func push_log(log_data):
	var line = HBoxContainer.new()
	var level = Label.new()
	var time = Label.new()
	var message = Label.new()

	level.text = "[" + Logger.get_level_string(log_data.level) + "]"
	time.text = str(Time.get_date_string_from_unix_time(log_data.time)) + " " + str(Time.get_time_string_from_unix_time(log_data.time))
	message.text = str(log_data.message)

	line.add_child(level)
	line.add_child(time)
	line.add_child(message)

	level.label_settings = LabelSettings.new()
	time.label_settings = LabelSettings.new()
	message.label_settings = LabelSettings.new()

	level.label_settings.font = load("res://assets/fonts/munro.ttf")
	time.label_settings.font = load("res://assets/fonts/munro.ttf")
	message.label_settings.font = load("res://assets/fonts/munro.ttf")

	level.label_settings.font_size = 12
	time.label_settings.font_size = 12
	message.label_settings.font_size = 12

	if log_data.level == Logger.Level.ERROR:
		level.label_settings.font_color = Color("#ef4444")
	elif log_data.level == Logger.Level.WARNING:
		level.label_settings.font_color = Color("#fb923c")
	else:
		level.label_settings.font_color = Color("#60a5fa")

	time.label_settings.font_color = Color("#a8a29e")
	message.label_settings.font_color = Color("#e7e5e4")

	vbox.add_child(line)
	set_deferred("scroll_vertical", vbox.size.y)

func _on_log_updated(log_data):
	push_log(log_data)

func handle_scrollbar_changed():
	var scrollbar = scroll.get_v_scroll_bar()
	if max_scroll_length != scrollbar.max_value: 
		max_scroll_length = scrollbar.max_value 
		scroll.scroll_vertical = max_scroll_length

		 
