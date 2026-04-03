@tool
extends MarginContainer

@onready var enable_panel: PanelContainer = %EnablePanel
@onready var disable_panel: PanelContainer = %DisablePanel

func _ready():
	_refresh()

func _on_enable_button_pressed() -> void:
	WorkspacesPluginSettings.instance.themes_enabled = true
	_refresh()

func _on_disable_button_pressed() -> void:
	WorkspacesPluginSettings.instance.themes_enabled = false
	_refresh()

func _refresh():
	if not WorkspacesPluginSettings.instance:
		return
	enable_panel.visible = not WorkspacesPluginSettings.instance.themes_enabled
	disable_panel.visible = WorkspacesPluginSettings.instance.themes_enabled
