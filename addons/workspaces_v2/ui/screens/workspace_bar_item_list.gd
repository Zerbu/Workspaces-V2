@tool
extends ItemList

var _selectable_workspaces: Array[WorkspaceV2]

func _ready():
	_refresh()
	WorkspacesPluginSettings.instance.active_group_changed.connect(func(new, previous):
		_refresh()
	)
	WorkspacesPluginSettings.instance.active_workspace_changed.connect(func(new, previous):
		_refresh()
	)

func _refresh():
	clear()
	_selectable_workspaces.clear()
	
	var index = 0
	for workspace in WorkspacesPluginSettings.instance.get_workspaces_in_active_group():
		add_item(workspace.workspace_name)
		_selectable_workspaces.append(workspace)
		if WorkspacesPluginSettings.instance.get_active_workspace() == workspace:
			select(index)
		index += 1

func _get_drag_data(at_position: Vector2) -> Variant:
	var index = get_item_at_position(at_position)
	if index == -1:
		return null
	var label = Label.new()
	label.text = get_item_text(index)
	set_drag_preview(label)
	return WorkspacesPluginSettings.instance.get_workspaces_in_active_group()[index]

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is WorkspaceV2:
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var over_index = get_item_at_position(at_position)
	var workspace: WorkspaceV2 = data
	WorkspacesPluginSettings.instance.move_workspace(workspace, over_index)

func _on_item_selected(index: int) -> void:
	if index == -1:
		return
	WorkspacesPluginSettings.instance.change_workspace(_selectable_workspaces[index])
