@tool
extends MarginContainer

@onready var _option_button: OptionButton = %OptionButton

var _selectable_groups: Array[WorkspaceGroup]

func _ready():
	_refresh()
	WorkspacesPluginSettings.instance.active_group_changed.connect(func(new, previous):
		_refresh()
	)
	WorkspacesPluginSettings.instance.active_workspace_changed.connect(func(new, previous):
		_refresh()
	)

func _refresh():
	_option_button.clear()
	_selectable_groups.clear()

	var index = 0
	for group in WorkspacesPluginSettings.instance.get_groups():
		_option_button.add_item(group.group_name)
		_selectable_groups.append(group)
		if group == WorkspacesPluginSettings.instance.get_active_group():
			_option_button.select(index)
		index = index + 1

func _on_option_button_item_selected(index: int) -> void:
	if index == -1:
		return
	var group = _selectable_groups[index]
	WorkspacesPluginSettings.instance.change_group(group)
