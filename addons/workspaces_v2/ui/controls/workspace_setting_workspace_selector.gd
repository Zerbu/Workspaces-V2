@tool
extends MarginContainer

@export var _name_text: String
@export_multiline var _info_text: String
@export var _editing_property: StringName

var _editing_resource: Resource

@onready var _name_label: Label = %NameLabel
@onready var _option_button: OptionButton = %OptionButton

var _selectable_workspaces: Array[WorkspaceV2]

func _ready():
	_name_label.text = _name_text
	_refresh()

func apply():
	if not _editing_resource:
		return
	_editing_resource.set(_editing_property, get_selected_workspace())

func edit(resource: Resource):
	if not _editing_property: return
	
	_editing_resource = resource
	if not _editing_resource: return
	
	_refresh()

func get_selected_workspace() -> WorkspaceV2:
	var index = _option_button.selected
	return _selectable_workspaces[index]

func _refresh():
	if not _editing_resource:
		return
	
	_option_button.clear()
	_selectable_workspaces.clear()
	
	_option_button.add_item("")
	_selectable_workspaces.append(null)

	var index = 1
	for workspace in WorkspacesPluginSettings.instance.get_workspaces_in_active_group():
		_option_button.add_item(workspace.workspace_name)
		_selectable_workspaces.append(workspace)
		if workspace == _editing_resource.get(_editing_property):
			_option_button.select(index)
		index = index + 1
