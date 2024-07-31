extends Node

func load(file: String, dir: String = '') -> Resource:
	for file_name in DirAccess.get_files_at("res://assets/" + dir):
		if (file_name.get_extension() == "import"):
			file_name = file_name.replace('.import', '')
			return ResourceLoader.load("res://assets/" + file)

	return null