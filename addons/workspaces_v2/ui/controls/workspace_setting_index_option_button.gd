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

func _ready():
	_option_button.clear()
	for option in _options:
		_option_button.add_item(option)
	_name_label.text = _name_text

func apply() -> void:
	if not _editing_resource:
		return
	_editing_resource.set(_editing_property, _option_button.selected)

func edit(resource: Resource):
	if not _editing_property: return
	
	_editing_resource = resource
	if not _editing_resource: return
	
	_option_button.select(_editing_resource.get(_editing_property))
