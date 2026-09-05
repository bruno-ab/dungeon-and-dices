extends CanvasLayer

signal closed

@onready var panel: PanelContainer = $Panel
@onready var title_l: Label = $Panel/Margin/VBox/Title
@onready var body_l: RichTextLabel = $Panel/Margin/VBox/Body
@onready var continue_btn: Button = $Panel/Margin/VBox/ContinueBtn

var _lines: PackedStringArray = []
var _index: int = 0
var _on_finished: Callable = Callable()


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_btn.pressed.connect(_on_continue)


func show_dialogue(speaker: String, lines: PackedStringArray, on_finished: Callable = Callable()) -> void:
	_lines = lines
	_index = 0
	_on_finished = on_finished
	title_l.text = speaker
	visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_show_current()
	continue_btn.grab_focus()


func _show_current() -> void:
	if _index >= _lines.size():
		_finish()
		return
	body_l.text = _lines[_index]


func _on_continue() -> void:
	_index += 1
	_show_current()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_on_continue()
		get_viewport().set_input_as_handled()


func _finish() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()
	if _on_finished.is_valid():
		_on_finished.call()
