@tool
extends MarginContainer

@export var _name_text: String
@export_multiline var _info_text: String
@export var _editing_property: StringName
@export var _options: Array[String]

var _editing_resource: Resource
var _is_refreshing: bool

@onready var _name_label: Label = %NameLabel
@onready var _option_button: OptionButton = %OptionButton
@onready var _line_edit: LineEdit = %LineEdit

func _ready():
	_option_button.clear()
	_option_button.add_item("")
	for option in _options:
		_option_button.add_item(option)
	_name_label.text = _name_text

func apply() -> void:
	if not _editing_resource:
		return
	_editing_resource.set(_editing_property, _line_edit.text)

func edit(resource: Resource):
	if not _editing_property: return
	
	_editing_resource = resource
	if not _editing_resource: return
	_line_edit.text = _editing_resource.get(_editing_property)
	_refresh(true)

func _refresh(option_button_only: bool = false):
	if _is_refreshing:
		return
	_is_refreshing = true
	if not option_button_only and not _line_edit.has_focus():
		_line_edit.text = _option_button.text
	_option_button.select(0)
	for i in range(_option_button.item_count-1):
		var text = _option_button.get_item_text(i)
		if text == _line_edit.text:
			_option_button.select(i)
	_is_refreshing = false

func _on_line_edit_text_changed(new_text: String) -> void:
	_refresh()

func _on_option_button_item_selected(index: int) -> void:
	_refresh()
