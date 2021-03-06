extends Control

signal unpause

var lobby = preload('res://menu/Lobby.tscn').instance()

func _ready() -> void:
	$'VBoxContainer/resume'.connect('pressed', self, '_on_resume')
	$'VBoxContainer/menu'.connect('pressed', self, '_on_menu')
	$'VBoxContainer/quit'.connect('pressed', self, '_on_quit')

func _unhandled_input(event) -> void:
	if event.is_action_pressed('pause'):
		emit_signal('unpause')
		queue_free()

	get_node('/root').get_tree().set_input_as_handled()

func _on_resume() -> void:
	emit_signal('unpause')
	queue_free()

func _on_menu() -> void:
	get_tree().get_root().add_child(lobby)
	get_node('/root/main').queue_free()
	queue_free()

func _on_quit() -> void:
	get_tree().quit()
