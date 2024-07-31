extends Node

var saved_recipes: Array = []
var current_customer = 'npc_carsen'
var customers_left = [
	'npc_carsen',
	'npc_buttercup',
	'npc_apollo',
	'npc_westley',
	'npc_vel'
]
var submitted_drink = {
	'npc_carsen': {
		'base': '',
		'toppings': [],
		'sinkers': [],
		'potion': ''
	},
	'npc_buttercup': {
		'base': '',
		'toppings': [],
		'sinkers': [],
		'potion': ''
	},
	'npc_apollo': {
		'base': '',
		'toppings': [],
		'sinkers': [],
		'potion': ''
	},
	'npc_westley': {
		'base': '',
		'toppings': [],
		'sinkers': [],
		'potion': ''
	},
	'npc_vel': {
		'base': '',
		'toppings': [],
		'sinkers': [],
		'potion': ''
	}
}
var npc_state = 0
var npc_conversation = ''
var current_customer_coversation = ""
var saved_potion: String = ""
var saved_drink_data: Dictionary = {
	"toppings": [],
	"sinkers": [],
	"base": ""
}

# temp
var sent_drink = false


var file_path = "user://savefile.json"

signal data_saved

func _ready():
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text()
		var json_data = JSON.parse_string(content)

		if json_data != null:
			saved_recipes = json_data["recipes"] as Array if json_data["recipes"] != null else []
			current_customer = json_data["customer"] if json_data["customer"] != null else 'npc_carsen'
			saved_potion = json_data["potion"] if json_data.has('potion') and json_data["potion"] != null else ""
			npc_state = json_data["npc_state"] if json_data.has('npc_state') and json_data["npc_state"] != null else 0
			npc_conversation = json_data["npc_conversation"] if json_data.has('npc_conversation') and json_data["npc_conversation"] != null else ""
			var has_drink_data = json_data.has("drink_data")
			var has_toppings = has_drink_data and json_data["drink_data"].has("toppings")
			var has_sinkers = has_drink_data and json_data["drink_data"].has("sinkers")
			var has_base = has_drink_data and json_data["drink_data"].has("base") and json_data["drink_data"]["base"] != ""

			var cafe = Resources.get_all_data(Resources.Configuration.CAFE)

			var base_data = cafe.filter(func(v):
				return v["layer"] == "base"
			)

			saved_drink_data = {
				"toppings": json_data["drink_data"]['toppings'] if has_toppings else [],
				"sinkers": json_data["drink_data"]['sinkers'] if has_sinkers else [],
				"base": json_data["drink_data"]['base'] if has_base else base_data[0]['id']
			}

			var has_customers_left = json_data.has("customers_left") and json_data["customers_left"] != null
			customers_left = json_data["customers_left"] if has_customers_left else [
				'npc_carsen',
			]

			var has_submitted_drink = json_data.has("submitted_drink") and json_data["submitted_drink"] != null
			submitted_drink = json_data["submitted_drink"] if has_submitted_drink else {
				'npc_carsen': {
					'base': '',
					'toppings': [],
					'sinkers': [],
					'potion': ''
				},
				'npc_buttercup': {
					'base': '',
					'toppings': [],
					'sinkers': [],
					'potion': ''
				},
				'npc_apollo': {
					'base': '',
					'toppings': [],
					'sinkers': [],
					'potion': ''
				},
				'npc_westley': {
					'base': '',
					'toppings': [],
					'sinkers': [],
					'potion': ''
				},
				'npc_vel': {
					'base': '',
					'toppings': [],
					'sinkers': [],
					'potion': ''
				}
			}

			save_data(func(data):
				return data
			)
	pass

func save_data(callable: Callable):
	var data = {
		"recipes": saved_recipes,
		"customer": current_customer,
		"potion": saved_potion,
		"drink_data": saved_drink_data,
		"customers_left": customers_left,
		"submitted_drink": submitted_drink,
		"npc_state": npc_state,
		"npc_conversation": npc_conversation
	}

	var new_data = callable.call(data)

	saved_recipes = new_data["recipes"]
	current_customer = new_data["customer"]
	saved_potion = new_data["potion"]
	saved_drink_data = new_data["drink_data"]
	customers_left = new_data["customers_left"]
	submitted_drink = new_data["submitted_drink"]
	npc_state = new_data["npc_state"]
	npc_conversation = new_data["npc_conversation"]

	var file = FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(new_data, "\t"))
		file.close()
		emit_signal("data_saved")
	pass

func reset():
	saved_recipes = []
	current_customer = 'npc_carsen'
	customers_left = [
		'npc_carsen',
		'npc_buttercup',
		'npc_apollo',
		'npc_westley',
		'npc_vel'
	]
	submitted_drink = {
		'npc_carsen': {
			'base': '',
			'toppings': [],
			'sinkers': [],
			'potion': ''
		},
		'npc_buttercup': {
			'base': '',
			'toppings': [],
			'sinkers': [],
			'potion': ''
		},
		'npc_apollo': {
			'base': '',
			'toppings': [],
			'sinkers': [],
			'potion': ''
		},
		'npc_westley': {
			'base': '',
			'toppings': [],
			'sinkers': [],
			'potion': ''
		},
		'npc_vel': {
			'base': '',
			'toppings': [],
			'sinkers': [],
			'potion': ''
		}
	}
	npc_state = 0
	npc_conversation = ''
	current_customer_coversation = ""
	saved_potion = ""
	saved_drink_data = {
		"toppings": [],
		"sinkers": [],
		"base": ""
	}
	sent_drink = false

	save_data(func(data):
		return data
	)
	pass