extends Button

@export var target_scene: PackedScene

func _on_button_up():
	get_tree().change_scene_to_file(target_scene.resource_path)
