@tool
extends MarginContainer

@onready var _menu_button: MenuButton = %MenuButton

var _menu_button_file_paths: Array[String]

func _ready():
	GrapplerFileSystem.filesystem_dock.selection_changed.connect(_on_filesystem_dock_selection_changed)
	_menu_button.get_popup().index_pressed.connect(_on_menu_popup_item_selected)

func _on_filesystem_dock_selection_changed():
	var menu_popup = _menu_button.get_popup()
	
	menu_popup.clear()
	_menu_button_file_paths.clear()
	
	for path in EditorInterface.get_selected_paths():
		var dir = path.get_base_dir()
		var base = path.get_file().get_basename()

		for file in DirAccess.get_files_at(dir):
			if file.get_basename() == base:
				var full_path = dir.path_join(file)
				
				if full_path == path:
					continue
				
				_menu_button_file_paths.append(full_path)
				menu_popup.add_item(file)

func _on_menu_popup_item_selected(index: int) -> void:
	var path = _menu_button_file_paths[index-1]
	
	# This is done twice to ensure the editor registers that a file is being opened instead of just switching to its tab
	GrapplerFileSystem.open_file(path)
	await get_tree().process_frame
	GrapplerFileSystem.open_file(path)

func _on_menu_popup_item_selected_inner(path: String) -> void:
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
