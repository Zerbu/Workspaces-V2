@tool
extends MarginContainer

@export var _name_text: String
@export_multiline var _info_text: String
@export var _editing_property: StringName

var _editing_resource: Resource

@onready var _check_box: CheckBox = %CheckBox
@onready var _info_label: Label = %InfoLabel

func _ready():
	_check_box.text = _name_text
	_info_label.text = _info_text
	_info_label.visible = _info_text != ""

func apply() -> void:
	if not _editing_resource:
		return
	_editing_resource.set(_editing_property, _check_box.button_pressed)

func edit(resource: Resource):
	if not _editing_property:
		return
	
	_editing_resource = resource
	if not _editing_resource:
		return
	_check_box.button_pressed = _editing_resource.get(_editing_property)
