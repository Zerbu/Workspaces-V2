@tool
class_name WorkspacesPluginSettings
extends Resource

static var instance: WorkspacesPluginSettings:
	get:
		if not instance:
			if ResourceLoader.exists("res://workspaces_v2.tres"):
				instance = ResourceLoader.load("res://workspaces_v2.tres")
				instance._on_load()
			else:
				instance = ResourceLoader.load("res://addons/workspaces_v2/data/default_settings.tres").duplicate(true)
				instance.take_over_path("res://workspaces_v2.tres")
		return instance	

signal active_group_changed(new_group: WorkspaceGroup, previous_group: WorkspaceGroup)
signal active_workspace_changed(new_workspace: WorkspaceV2, previous_workspace: WorkspaceV2)

@export var _groups: Array[WorkspaceGroup]
@export var _workspaces: Array[WorkspaceV2]

@export var _active_group: WorkspaceGroup
@export var _active_workspace: WorkspaceV2

@export var auto_switch_enabled: bool = true
@export var themes_enabled: bool

func add_group(new_group: WorkspaceGroup):
	_groups.append(new_group)
	change_group(new_group)

func add_workspace(new_workspace: WorkspaceV2):
	_workspaces.append(new_workspace)
	change_workspace(new_workspace)

func change_group(new_group: WorkspaceGroup):
	_sort_groups()
	var previous_group = _active_group
	_active_group = new_group
	active_group_changed.emit(new_group, previous_group)
	save()

	var first: WorkspaceV2	
	var same_name: WorkspaceV2
	var same_layout: WorkspaceV2
	var index = 0
	var active_workspace = get_active_workspace()
	
	for workspace in get_workspaces_in_active_group():
		if index == 0:
			first = workspace
			if active_workspace == null:
				break
		if not same_name:
			if workspace.workspace_name == active_workspace.workspace_name:
				same_name = workspace
		if not same_layout:
			if workspace.layout_name == active_workspace.layout_name:
				same_layout = workspace
		index = index + 1
	
	if same_name:
		change_workspace(same_name)
	elif same_layout:
		change_workspace(same_layout)
	elif first:
		change_workspace(first)

func change_workspace(new_workspace: WorkspaceV2):
	if new_workspace == _active_workspace:
		return
	var previous_workspace = _active_workspace
	if previous_workspace:
		previous_workspace._unapply()
	_active_workspace = new_workspace
	if new_workspace:
		new_workspace._apply()
	active_workspace_changed.emit(new_workspace, previous_workspace)
	save()

func get_active_group() -> WorkspaceGroup:
	return _active_group

func get_active_workspace() -> WorkspaceV2:
	return _active_workspace

func get_index_of_workspace(workspace: WorkspaceV2) -> int:
	return _workspaces.find(workspace)

func get_groups() -> Array[WorkspaceGroup]:
	return _groups

func get_workspace_by_index(index: int) -> WorkspaceV2:
	if _workspaces.size() <= index:
		return null
	if index < 0:
		return null
	return _workspaces[index]

func get_workspaces() -> Array[WorkspaceV2]:
	return _workspaces

func get_workspaces_in_active_group() -> Array[WorkspaceV2]:
	if not _active_group:
		return []
	return get_workspaces_in_group(_active_group)

func get_workspaces_in_group(group: WorkspaceGroup) -> Array[WorkspaceV2]:
	var result: Array[WorkspaceV2] = []
	for workspace in get_workspaces():
		if workspace.is_in_group(group):
			result.append(workspace)
	return result

func is_group_valid(group: WorkspaceGroup) -> bool:
	if group not in _groups:
		return false
	return true

func move_workspace(workspace: WorkspaceV2, new_index: int):
	_workspaces.erase(workspace)
	_workspaces.insert(new_index, workspace)
	refresh_active_workspace()

func refresh_active_group():
	var group = get_active_group()
	change_group(null)
	change_group(group)

func refresh_active_workspace():
	var workspace = get_active_workspace()
	change_workspace(null)
	change_workspace(workspace)

func remove_group(group: WorkspaceGroup):
	_groups.erase(group)
	reset_group()

func remove_workspace(workspace: WorkspaceV2):
	_workspaces.erase(workspace)
	reset_workspace()

func reset_group():
	if _groups.size() == 0:
		return
	change_group(_groups[0])

func reset_workspace():
	if _workspaces.size() == 0:
		return
	change_workspace(_workspaces[0])

func _sort_groups():
	_groups.sort_custom(func(a, b):
		return a.group_name < b.group_name
	)

#region Auto Open
func _on_selected_file_changed():
	var workspace = get_active_workspace()
	if not workspace:
		return
	workspace._on_selected_file_changed()

#region Process
func _on_process(delta: float):
	_process_group()
	_process_workspace()

func _process_group():
	var group = get_active_group()
	if not group:
		return
	group._on_process()

func _process_workspace():
	var workspace = get_active_workspace()
	if not workspace:
		return
	workspace._on_process()

#region Lazy Process
func _on_lazy_process():
	_lazy_process_group()
	_lazy_process_workspace()

func _lazy_process_group():
	var group = get_active_group()
	if not group:
		return
	group._on_lazy_process()

func _lazy_process_workspace():
	var workspace = get_active_workspace()
	if not workspace:
		return
	workspace._on_lazy_process()

#region Save/Load
func save():
	for workspace in get_workspaces():
		workspace._on_save()
	ResourceSaver.save(self)

func _on_load():
	for workspace in get_workspaces():
		workspace._on_load()
