@tool
extends MarginContainer

@export var _name_text: String
@export_multiline var _info_text: String
@export var _editing_property: StringName

@export var _min_value: float = 0.0
@export var _max_value: float = 100.0
@export var _step: float = 1.0

var _editing_resource: Resource

@onready var _name_label: Label = %NameLabel
@onready var _spin_box: SpinBox = %SpinBox
@onready var _info_label: Label = %InfoLabel

func _ready():
	_name_label.text = _name_text
	_info_label.text = _info_text
	
	if not _info_text:
		_info_label.hide()
	
	_spin_box.min_value = _min_value
	_spin_box.max_value = _max_value
	_spin_box.step = _step

func apply() -> void:
	if not _editing_resource:
		return
	
	_editing_resource.set(_editing_property, _spin_box.value)

func edit(resource: Resource):
	if not _editing_property:
		return
	
	_editing_resource = resource
	if not _editing_resource:
		return
	
	var value = _editing_resource.get(_editing_property)
	if value == null:
		value = 0
	
	_spin_box.value = value
