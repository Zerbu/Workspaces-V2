@tool
extends MarginContainer

@export var _name_text: String
@export_multiline var _info_text: String
@export var _editing_property: StringName

var _editing_resource: Resource

@onready var _name_label: Label = %NameLabel
@onready var _text_edit: TextEdit = %TextEdit
@onready var _info_label: Label = %InfoLabel

func _ready():
	_name_label.text = _name_text
	_info_label.text = _info_text
	_info_label.visible = _info_text != null

func apply() -> void:
	if not _editing_resource:
		return
	_editing_resource.set(_editing_property, _text_edit.text)

func edit(resource: Resource):
	if not _editing_property: return
	
	_editing_resource = resource
	if not _editing_resource: return
	_text_edit.text = _editing_resource.get(_editing_property)
