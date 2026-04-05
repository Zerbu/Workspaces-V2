@tool
extends MarginContainer

enum MenuItems
{
	GROUP_SETTINGS = 0,
	WORKSPACE_SETTINGS = 1,
	NEW_GROUP = 2,
	NEW_WORKSPACE = 3,
	DELETE_GROUP = 4,
	DELETE_WORKSPACE = 5,
	UNHIDE = 6,
	SAVE_CURRENT_LAYOUT = 7,
	TOGGLE_AUTO_SWITCH = 8
}

var workspace_settings_menu = preload("res://addons/workspaces_v2/ui/screens/workspace_settings_menu.tscn")
var workspace_group_settings_menu = preload("res://addons/workspaces_v2/ui/screens/workspace_group_settings_menu.tscn")

@onready var menu_button: MenuButton = %MenuButton

func _ready():
	menu_button.get_popup().id_pressed.connect(_on_menu_button_id_pressed)
	_refresh_menu_text()

func _on_menu_button_id_pressed(id: int):
	match id:
		MenuItems.GROUP_SETTINGS:
			_open_group_settings()
		MenuItems.WORKSPACE_SETTINGS:
			_open_workspace_settings()
		MenuItems.NEW_GROUP:
			_create_group()
		MenuItems.NEW_WORKSPACE:
			_create_workspace()
		MenuItems.DELETE_GROUP:
			_delete_group()
		MenuItems.DELETE_WORKSPACE:
			_delete_workspace()
		MenuItems.UNHIDE:
			_unhide()
		MenuItems.SAVE_CURRENT_LAYOUT:
			_save_current_layout()
		MenuItems.TOGGLE_AUTO_SWITCH:
			WorkspacesPluginSettings.instance.auto_switch_enabled = not WorkspacesPluginSettings.instance.auto_switch_enabled
			_refresh_menu_text()

func _open_workspace_settings():
	var workspace = WorkspacesPluginSettings.instance.get_active_workspace()
	var menu = workspace_settings_menu.instantiate()
	menu.workspace = workspace
	GrapplerWindows.open_simple_window(workspace.workspace_name, menu)

func _open_group_settings():
	var group = WorkspacesPluginSettings.instance.get_active_group()
	var menu = workspace_group_settings_menu.instantiate()
	menu.group = group
	GrapplerWindows.open_simple_window(group.group_name, menu)

func _create_group():
	var group = WorkspaceGroup.new()
	group.group_name = "New Group"
	WorkspacesPluginSettings.instance.add_group(group)
	_open_group_settings()

func _create_workspace():
	var workspace = WorkspaceV2.new()
	workspace.workspace_name = "New Workspace"
	workspace.add_to_group(WorkspacesPluginSettings.instance.get_active_group())
	
	var active_workspace = WorkspacesPluginSettings.instance.get_active_workspace()
	if active_workspace:
		workspace.theme_accent_color = active_workspace.theme_accent_color
		workspace.theme_additional_spacing = active_workspace.theme_additional_spacing
		workspace.theme_base_color = active_workspace.theme_base_color
		workspace.theme_base_spacing = active_workspace.theme_base_spacing
		workspace.theme_contrast = active_workspace.theme_contrast
	
	WorkspacesPluginSettings.instance.add_workspace(workspace)
	_open_workspace_settings()

func _delete_group():
	var group = WorkspacesPluginSettings.instance.get_active_group()
	if not group:
		return
	WorkspacesPluginSettings.instance.remove_group(group)

func _delete_workspace():
	var workspace = WorkspacesPluginSettings.instance.get_active_workspace()
	if not workspace:
		return
	WorkspacesPluginSettings.instance.remove_workspace(workspace)

func _refresh_menu_text():
	var popup = menu_button.get_popup()
	if WorkspacesPluginSettings.instance.auto_switch_enabled:
		popup.set_item_text(popup.item_count-1, "Toggle Auto Switch (Currently Enabled)")
	else:
		popup.set_item_text(popup.item_count-1, "Toggle Auto Switch (Currently Disabled)")

func _unhide():
	WorkspaceV2.unhide_features()

func _save_current_layout():
	GrapplerLayoutsDialog.force_save_layout(WorkspacesPluginSettings.instance.get_active_workspace().layout_name)
