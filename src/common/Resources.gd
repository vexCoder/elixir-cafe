extends Node

enum Configuration {
	DIALOGUE = 0,
	INGREDIENT = 1,
	RECIPES = 2,
	CUSTOMER = 3,
	CAFE = 4,
}

var data = []

var configurations = [
	"dialogues.json",
	"ingredients.json",
	"recipes.json",
	"customers.json",
	"cafe.json",
]

func read_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return content

func _init():
	for config in configurations:
		var file = read_file("res://config/" + config)
		var json = JSON.new()
		var res = json.parse(file)
		if res == OK:
			data.append(json.data)
		else:
			print("Error parsing JSON file: " + config)
	pass;

func get_data(key: Configuration, callable: Callable):
	if data.size() == 0:
		return null
	var content = data[key] as Array
	var filtered = content.filter(callable)
	if(filtered.size() > 0):
		return filtered[0]
	return null

func get_all_data(key: Configuration):
	if data.size() == 0:
		return null
	return data[key] as Array
