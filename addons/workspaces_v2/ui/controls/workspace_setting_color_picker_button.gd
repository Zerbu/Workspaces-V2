@tool
extends MarginContainer

@export var _name_text: String
@export_multiline var _info_text: String
@export var _editing_property: StringName

var _editing_resource: Resource

@onready var _name_label: Label = %NameLabel
@onready var _color_button: ColorPickerButton = %ColorPickerButton
@onready var _info_label: Label = %InfoLabel

func _ready():
	_name_label.text = _name_text
	_info_label.text = _info_text
	
	if not _info_text:
		_info_label.hide()

func apply() -> void:
	if not _editing_resource:
		return
	
	_editing_resource.set(_editing_property, _color_button.color)

func edit(resource: Resource):
	if not _editing_property:
		return
	
	_editing_resource = resource
	if not _editing_resource:
		return
	
	var value = _editing_resource.get(_editing_property)
	if value == null:
		value = Color.WHITE
	
	_color_button.color = value
