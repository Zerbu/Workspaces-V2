@tool
extends MarginContainer

@onready var _option_button: OptionButton = $OptionButton

var _option_button_file_paths: Array[String]

func _ready():
	GrapplerFileSystem.filesystem_dock.selection_changed.connect(_on_filesystem_dock_selection_changed)

func _on_filesystem_dock_selection_changed():
	_option_button.clear()
	_option_button_file_paths.clear()
	
	_option_button.add_item("(Related Files)")
	
	for path in EditorInterface.get_selected_paths():
		var dir = path.get_base_dir()
		var base = path.get_file().get_basename()

		for file in DirAccess.get_files_at(dir):
			if file.get_basename() == base:
				var full_path = dir.path_join(file)
				
				_option_button_file_paths.append(full_path)
				_option_button.add_item(file)

func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		return

	var path = _option_button_file_paths[index-1]
	if path.get_extension() in ["tscn", "scn"]:
		EditorInterface.open_scene_from_path(path)
		var root = load(path).instantiate()
		if root is Node3D:
			EditorInterface.set_main_screen_editor("3D")
		else:
			EditorInterface.set_main_screen_editor("2D")
	else:
		EditorInterface.edit_resource(load(path))
		EditorInterface.set_main_screen_editor("Script")
