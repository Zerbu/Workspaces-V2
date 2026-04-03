@tool
class_name WorkspaceV2
extends Resource

enum FileSystemAutoNavigateTypes
{
	NONE,
	CURRENT_SCRIPT,
	CURRENT_SCENE,
	CURRENT_INSPECTOR_ITEM
}

# Main Settings
@export var workspace_name : String:
	set(value):
		workspace_name = value
		resource_name = value

@export var layout_name: String
@export var _groups: Array[WorkspaceGroup]

@export var filesystem_auto_navigate_type: FileSystemAutoNavigateTypes
@export var filesystem_auto_navigate_path: String
@export var auto_set_file_on_unapply: bool

@export var auto_set_main_screen: String
@export var force_save_layout: bool

@export var hide_menu_bar: bool
@export var hide_main_screen_buttons: bool
@export var hide_run_bar: bool
@export var hide_bottom_bar: bool
@export var hide_tabs_left_1_top: bool
@export var hide_tabs_left_1_bottom: bool
@export var hide_tabs_left_2_top: bool
@export var hide_tabs_left_2_bottom: bool
@export var hide_tabs_right_1_top: bool
@export var hide_tabs_right_1_bottom: bool
@export var hide_tabs_right_2_top: bool
@export var hide_tabs_right_2_bottom: bool
@export var hide_scene_tabs: bool
@export var hide_entire_middle_area: bool

@export var file_filter_names: String
@export var file_filter_extensions: String

@export var auto_switch_on_script: String
@export var auto_switch_on_2d: String
@export var auto_switch_on_3d: String
@export var auto_switch_on_game: String

@export var hide_tabs_bottom_left: bool
@export var hide_tabs_bottom_right: bool

var workspace_2d: WorkspaceV2
var workspace_3d: WorkspaceV2
var workspace_script: WorkspaceV2
var workspace_game: WorkspaceV2

@export var _workspace_2d_index: int
@export var _workspace_3d_index: int
@export var _workspace_script_index: int
@export var _workspace_game_index: int

# Themes
@export var theme_base_color: Color = Color.GRAY
@export var theme_accent_color: Color = Color.WHITE
@export var theme_contrast: float = 0.3
@export var theme_base_spacing: float = 4
@export var theme_additional_spacing: float = 0

func add_to_group(group: WorkspaceGroup):
	if group in _groups:
		return
	_groups.append(group)

func is_in_group(group: WorkspaceGroup) -> bool:
	return _groups.has(group)

func is_orphan():
	_clear_invalid_groups()
	return _groups.size() == 0

func remove_from_group(group: WorkspaceGroup):
	if not group in _groups:
		return
	_groups.erase(group)

func _apply():
	if layout_name:
		var layout = GrapplerPopupMenuUtils.get_id_from_text(GrapplerTitleBar.editor_layouts_menu, layout_name)
		if layout >= 0:
			GrapplerPopupMenuUtils.simulate_id_pressed(GrapplerTitleBar.editor_layouts_menu, layout)

	if auto_set_main_screen : GrapplerTitleBar.set_main_screen_from_string(auto_set_main_screen)

	_hide_features()

	_unlock_docks(Engine.get_main_loop().root)
	
	if WorkspacesPluginSettings.instance.themes_enabled:
		var settings = EditorInterface.get_editor_settings()

		if theme_base_color != settings.get_setting("interface/theme/base_color"):
			settings.set_setting("interface/theme/base_color", theme_base_color)

		if theme_accent_color != settings.get_setting("interface/theme/accent_color"):
			settings.set_setting("interface/theme/accent_color", theme_accent_color)

		var contrast = settings.get_setting("interface/theme/contrast")
		if contrast and not is_equal_approx(theme_contrast, contrast):
			settings.set_setting("interface/theme/contrast", theme_contrast)

		if theme_base_spacing != settings.get_setting("interface/theme/base_spacing"):
			settings.set_setting("interface/theme/base_spacing", theme_base_spacing)

		if theme_additional_spacing != settings.get_setting("interface/theme/additional_spacing"):
			settings.set_setting("interface/theme/additional_spacing", theme_additional_spacing)

	if filesystem_auto_navigate_path:
		# The frame delay is to ensure auto navigate takes priority over Layout changes when setting the scrollbar position 
		await Engine.get_main_loop().process_frame
		GrapplerFileSystem.filesystem_dock.navigate_to_path(filesystem_auto_navigate_path)

func _clear_invalid_groups():
	for group in _groups.duplicate():
		if not WorkspacesPluginSettings.instance.is_group_valid(group):
			_groups.erase(group)

func _hide_features():
	if hide_menu_bar:
		GrapplerTitleBar.menu_bar.hide()

	if hide_main_screen_buttons:
		GrapplerTitleBar.main_screen_buttons.hide()

	if hide_run_bar:
		GrapplerTitleBar.run_bar.hide()

	if hide_menu_bar and hide_main_screen_buttons and hide_run_bar:
		GrapplerTitleBar.title_bar.hide()

	if hide_bottom_bar:
		GrapplerDocks.bottom_panel.hide()

	if hide_tabs_left_1_top:
		GrapplerDocks.left_dock_1_top_tab_container.tabs_visible = false

	if hide_tabs_left_1_bottom:
		GrapplerDocks.left_dock_1_bottom_tab_container.tabs_visible = false

	if hide_tabs_left_2_top:
		GrapplerDocks.left_dock_2_top_tab_container.tabs_visible = false

	if hide_tabs_left_2_bottom:
		GrapplerDocks.left_dock_2_bottom_tab_container.tabs_visible = false

	if hide_scene_tabs:
		GrapplerDocks.main_dock_scene_tabs.hide()

	if hide_tabs_right_1_top:
		GrapplerDocks.right_dock_1_top_tab_container.tabs_visible = false

	if hide_tabs_right_1_bottom:
		GrapplerDocks.right_dock_1_bottom_tab_container.tabs_visible = false

	if hide_tabs_right_2_top:
		GrapplerDocks.right_dock_2_top_tab_container.tabs_visible = false

	if hide_tabs_right_2_bottom:
		GrapplerDocks.right_dock_2_bottom_tab_container.tabs_visible = false

	if hide_entire_middle_area:
		GrapplerDocks.middle_vbox.hide()

	if GrapplerDocks.has_bottom_docks:
		if hide_tabs_bottom_left:
			GrapplerDocks.bottom_dock_left_tab_container.tabs_visible = false

		if hide_tabs_bottom_right:
			GrapplerDocks.bottom_dock_right_tab_container.tabs_visible = false

func _unlock_docks(node: Node):
	for child in node.get_children():
		if child is EditorDock:
			child.available_layouts = EditorDock.DOCK_LAYOUT_ALL
		_unlock_docks(child)

func _unapply():
	if force_save_layout:
		GrapplerLayoutsDialog.force_save_layout(layout_name)

	if auto_set_file_on_unapply:
		filesystem_auto_navigate_path = EditorInterface.get_current_path()

	unhide_features()

static func unhide_features():
	GrapplerTitleBar.menu_bar.show()
	GrapplerTitleBar.main_screen_buttons.show()
	GrapplerTitleBar.run_bar.show()
	GrapplerTitleBar.title_bar.show()
	GrapplerDocks.main_dock_scene_tabs.show()
	GrapplerDocks.middle_vbox.show()
	
	GrapplerDocks.bottom_panel.show()
	GrapplerDocks.left_dock_1_top_tab_container.tabs_visible = true
	GrapplerDocks.left_dock_1_bottom_tab_container.tabs_visible = true
	GrapplerDocks.left_dock_2_top_tab_container.tabs_visible = true
	GrapplerDocks.left_dock_2_bottom_tab_container.tabs_visible = true
	GrapplerDocks.right_dock_1_top_tab_container.tabs_visible = true
	GrapplerDocks.right_dock_1_bottom_tab_container.tabs_visible = true
	GrapplerDocks.right_dock_2_top_tab_container.tabs_visible = true
	GrapplerDocks.right_dock_2_bottom_tab_container.tabs_visible = true
	
	# Godot 4.7+
	if GrapplerDocks.has_bottom_docks:
		GrapplerDocks.bottom_dock_left_tab_container.tabs_visible = true
		GrapplerDocks.bottom_dock_right_tab_container.tabs_visible = true

func _on_process():
	if workspace_2d and GrapplerDocks.node_2d_and_ui_editor.is_visible_in_tree():
		WorkspacesPluginSettings.instance.change_workspace(workspace_2d)
		return
	elif workspace_3d and GrapplerDocks.node_3d_editor.is_visible_in_tree():
		WorkspacesPluginSettings.instance.change_workspace(workspace_3d)
		return
	elif workspace_script and GrapplerDocks.script_editor.is_visible_in_tree():
		WorkspacesPluginSettings.instance.change_workspace(workspace_script)
		return
	elif workspace_game and GrapplerDocks.game_view.is_visible_in_tree():
		WorkspacesPluginSettings.instance.change_workspace(workspace_game)
		return
	
	_process_auto_navigate()

func _process_auto_navigate():
	if GrapplerFileSystem.main_tree.has_focus():
		return
	if GrapplerFileSystem.file_list.has_focus():
		return
	
	match filesystem_auto_navigate_type:
		FileSystemAutoNavigateTypes.CURRENT_SCRIPT:
			var script_editor = EditorInterface.get_script_editor()
			var script = script_editor.get_current_script()
			if script:
				if EditorInterface.get_current_path() != script.resource_path:
					GrapplerFileSystem.filesystem_dock.navigate_to_path(script.resource_path)
		FileSystemAutoNavigateTypes.CURRENT_SCENE:
			var scene = EditorInterface.get_edited_scene_root()
			if not scene:
				return
			var scene_file = scene.scene_file_path
			if not scene_file:
				return
			if EditorInterface.get_current_path() != scene.scene_file_path:
				GrapplerFileSystem.filesystem_dock.navigate_to_path(scene.scene_file_path)
		FileSystemAutoNavigateTypes.CURRENT_INSPECTOR_ITEM:
			var obj = EditorInterface.get_inspector().get_edited_object()
			if obj is not Resource:
				return
			var path = obj.resource_path
			if not path:
				return
			if not FileAccess.file_exists(path):
				return
			if EditorInterface.get_current_path() != path:
				GrapplerFileSystem.filesystem_dock.navigate_to_path(path)

func _on_lazy_process():
	if file_filter_names:
		GrapplerTreeUtils.filter(GrapplerFileSystem.main_tree.get_root(),
		func(item: TreeItem):
			var text = item.get_text(0)
			for file_name in file_filter_names.replace("\r", "").split("\n"):
				if text == file_name:
					return true
			return false
		)
	if file_filter_extensions:
		if GrapplerFileSystem.file_list.is_visible_in_tree():
			GrapplerItemListUtils.filter_experimental(GrapplerFileSystem.file_list,
				func(index: int):
					var text := GrapplerFileSystem.file_list.get_item_text(index)

					for extension in file_filter_extensions.replace("\r", "").split("\n"):
						if extension.is_empty():
							continue

						if not extension.begins_with("."):
							extension = ".%s" % extension

						if text.get_file().ends_with(extension):
							return true

					return false
			)
		else:
			GrapplerTreeUtils.filter(GrapplerFileSystem.main_tree.get_root(),
			func(item: TreeItem):
				var text = item.get_text(0)
				for extension in file_filter_extensions.replace("\r", "").split("\n"):
					if not extension.begins_with("."):
						extension = ".%s" % extension
					if text.get_file().ends_with(extension):
						return true
				return false
			)

#region Save/Load
func _on_save():
	_workspace_2d_index = WorkspacesPluginSettings.instance.get_index_of_workspace(workspace_2d)
	_workspace_3d_index = WorkspacesPluginSettings.instance.get_index_of_workspace(workspace_3d)
	_workspace_script_index = WorkspacesPluginSettings.instance.get_index_of_workspace(workspace_script)
	_workspace_game_index = WorkspacesPluginSettings.instance.get_index_of_workspace(workspace_game)

func _on_load():
	workspace_2d = WorkspacesPluginSettings.instance.get_workspace_by_index(_workspace_2d_index)
	workspace_3d = WorkspacesPluginSettings.instance.get_workspace_by_index(_workspace_3d_index)
	workspace_script = WorkspacesPluginSettings.instance.get_workspace_by_index(_workspace_script_index)
	workspace_game = WorkspacesPluginSettings.instance.get_workspace_by_index(_workspace_game_index)
