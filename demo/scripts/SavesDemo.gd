extends Control

@onready var scoreField: TextEdit = $TextEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	scoreField.text = _load()

func _on_button_button_up():
	_save(scoreField.text)

func _save(score: String) -> void:
	var directory = GxGames.generate_data_path()
	
	if !directory:
		directory = "user://"
	
	var file_path = directory + 'save'
	print('Saving into ' + file_path)
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(score)

func _load() -> String:
	var directory = GxGames.generate_data_path()
	
	if !directory:
		directory = "user://"
	
	var file_path = directory + 'save'
	print('Loading from ' + file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		return file.get_as_text()
	else:
		return "0"
	
