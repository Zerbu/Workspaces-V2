@tool
extends MarginContainer

var workspace: WorkspaceV2

@onready var workspace_selector_2d: MarginContainer = %WorkspaceSelector2D
@onready var workspace_selector_3d: MarginContainer = %WorkspaceSelector3D
@onready var workspace_selector_script: MarginContainer = %WorkspaceSelectorScript
@onready var workspace_selector_game: MarginContainer = %WorkspaceSelectorGame

@onready var file_system_auto_navigate_path_container: VBoxContainer = %FileSystemAutoNavigatePathContainer

func _ready():
	for control in get_tree().get_nodes_in_group("workspace_setting_controls"):
		control.edit(workspace)

func _on_save_workspace_button_pressed() -> void:
	for control in get_tree().get_nodes_in_group("workspace_setting_controls"):
		control.apply()
	WorkspacesPluginSettings.instance.refresh_active_workspace()
	GrapplerWindows.close_window_of_node(self)

func _on_copy_to_group_button_pressed() -> void:
	for group_workspace in WorkspacesPluginSettings.instance.get_workspaces_in_active_group():
		group_workspace.workspace_2d = workspace_selector_2d.get_selected_workspace()
		group_workspace.workspace_3d = workspace_selector_3d.get_selected_workspace()
		group_workspace.workspace_script = workspace_selector_script.get_selected_workspace()
		group_workspace.workspace_game = workspace_selector_game.get_selected_workspace()

func _on_copy_theme_button_pressed() -> void:
	for group_workspace in WorkspacesPluginSettings.instance.get_workspaces_in_active_group():
		group_workspace.theme_accent_color = workspace.theme_accent_color
		group_workspace.theme_additional_spacing = workspace.theme_additional_spacing
		group_workspace.theme_base_color = workspace.theme_base_color
		group_workspace.theme_base_spacing = workspace.theme_base_spacing
		group_workspace.theme_contrast = workspace.theme_contrast
