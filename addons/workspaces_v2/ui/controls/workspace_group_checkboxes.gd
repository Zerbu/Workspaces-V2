@tool
extends MarginContainer

@export var _editing_property: StringName

var _editing_resource: Resource

var _groups: Array[WorkspaceGroup]

@onready var container: VBoxContainer = %Container

func apply():
	var workspace: WorkspaceV2 = _editing_resource
	var index = 0
	for checkbox: CheckBox in container.get_children():
		if checkbox.button_pressed:
			workspace.add_to_group(_groups[index])
		else:
			workspace.remove_from_group(_groups[index])
		index = index + 1

func edit(resource: Resource):
	if not _editing_property:
		return
	
	_editing_resource = resource
	if not _editing_resource:
		return
	
	var workspace: WorkspaceV2 = _editing_resource
	
	for child in container.get_children():
		child.queue_free()
	
	for group in WorkspacesPluginSettings.instance.get_groups():
		var checkbox = CheckBox.new()
		checkbox.text = group.group_name
		checkbox.button_pressed = workspace.is_in_group(group)
		container.add_child(checkbox)
		_groups.append(group)
