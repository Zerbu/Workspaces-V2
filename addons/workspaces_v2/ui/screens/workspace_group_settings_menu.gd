@tool
extends MarginContainer

var group: WorkspaceGroup

@onready var save_group_button: Button = %SaveGroupButton

func _ready():
	for control in get_tree().get_nodes_in_group("workspace_group_setting_controls"):
		control.edit(group)

func _on_save_group_button_pressed() -> void:
	for control in get_tree().get_nodes_in_group("workspace_group_setting_controls"):
		control.apply()
	WorkspacesPluginSettings.instance.refresh_active_group()
	GrapplerWindows.close_window_of_node(self)
