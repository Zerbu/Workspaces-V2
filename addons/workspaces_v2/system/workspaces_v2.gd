@tool
extends EditorPlugin

#region Variables
var relations_dropdown = preload("res://addons/workspaces_v2/ui/screens/file_relations_dropdown.tscn").instantiate()
var workspace_bar = preload("res://addons/workspaces_v2/ui/screens/workspace_bar.tscn").instantiate()

var lazy_process_timer: Timer

#region Enable and Process
func _enter_tree() -> void:
	_delete_orphan_workspaces()
	_add_workspace_bar()
	_add_relations_dropdown()
	_setup_lazy_process()
	WorkspacesPluginSettings.instance.refresh_active_workspace()

func _delete_orphan_workspaces():
	var deleted_any = false
	for workspace in WorkspacesPluginSettings.instance.get_workspaces():
		if workspace.is_orphan():
			WorkspacesPluginSettings.instance.remove_workspace(workspace)
			print("Orphan workspace deleted: %s" % workspace.workspace_name)
			deleted_any = true
	if deleted_any:
		WorkspacesPluginSettings.instance.save()

func _add_workspace_bar():
	GrapplerBase.root_vbox.add_child(workspace_bar)
	GrapplerBase.root_vbox.move_child(workspace_bar, 0)

func _add_relations_dropdown():
	GrapplerFileSystem.header_vbox.add_child(relations_dropdown)
	GrapplerFileSystem.header_vbox.move_child(relations_dropdown, 0)

func _setup_lazy_process():
	lazy_process_timer = Timer.new()
	lazy_process_timer.wait_time = 0.1
	lazy_process_timer.timeout.connect(func():
		WorkspacesPluginSettings.instance._on_lazy_process()
	)
	add_child(lazy_process_timer)
	lazy_process_timer.start()

func _process(delta: float):
	WorkspacesPluginSettings.instance._on_process(delta)

#region Disable
func _exit_tree() -> void:
	_remove_workspace_bar()
	_remove_relations_dropdown()
	_destroy_lazy_process()

func _remove_workspace_bar():
	GrapplerBase.root_vbox.remove_child(workspace_bar)

func _remove_relations_dropdown():
	GrapplerFileSystem.header_vbox.remove_child(relations_dropdown)

func _destroy_lazy_process():
	lazy_process_timer.queue_free()
