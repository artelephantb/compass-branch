extends Node2D

@onready var text_box = $'TextEdit'
@onready var frame_slider = $'FrameSlider'
@onready var replay_button = $'ReplayButton'
@onready var record_button = $'RecordButton'
@onready var plays_timer_toggle  = $'PlaysTimerToggle'
@onready var export_dialog  = $'ExportDialog'
@onready var import_dialog  = $'ImportDialog'

var text_logs = []
var timed_text_logs = []

var plays_timer = false

var replaying = false

var wait_frames = 0
var current_wait_frame = 0

var recording = false


func replay() -> void:
	current_wait_frame = 0
	wait_frames = 0

	text_box.editable = false

	text_box.text = ''
	frame_slider.value = 0.0
	replaying = true

	recording = false


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if !replaying:
		replay_button.disabled = false
		record_button.disabled = false

		record_button.text = 'Stop Recording' if recording else 'Start Recording'
		if recording:
			wait_frames += 1
		else:
			wait_frames = 0
		return
	replay_button.disabled = true
	record_button.disabled = true

	if frame_slider.value == frame_slider.max_value:
		replaying = false
		text_box.editable = true
		return

	var current_character = ''
	if plays_timer:
		current_character = timed_text_logs[frame_slider.value + 1]
	else:
		current_character = text_logs[frame_slider.value + 1]

	if typeof(current_character) == TYPE_STRING:
		text_box.text = current_character
		frame_slider.value += 1
		return

	if current_wait_frame == 0:
		current_wait_frame = current_character
		return

	current_wait_frame -= 1
	if current_wait_frame == 0:
		frame_slider.value += 1


func _on_text_box_edited() -> void:
	if !recording:
		return
	text_logs.append(text_box.text)
	timed_text_logs.append(wait_frames)
	timed_text_logs.append(text_box.text)
	wait_frames = 0

func _on_replay_pressed() -> void:
	replay()

func _on_record_pressed() -> void:
	recording = !recording
	if recording:
		text_logs.append(text_box.text)
		frame_slider.editable = false
	else:
		frame_slider.max_value = len(text_logs) - 1
		frame_slider.editable = true

func _on_save_pressed() -> void:
	recording = false
	replaying = false
	text_box.editable = true
	export_dialog.popup()

func _on_export_dialog_file_selected(path: String) -> void:
	var saved_file = FileAccess.open(path, FileAccess.WRITE)
	saved_file.store_string(str([text_logs, timed_text_logs]))

func _on_import_button_pressed() -> void:
	recording = false
	replaying = false
	text_box.editable = true
	import_dialog.popup()

func _on_import_dialog_file_selected(path: String) -> void:
	var read_file = FileAccess.open(path, FileAccess.READ)
	var file_content = str_to_var(read_file.get_as_text())
	text_logs = file_content[0]
	timed_text_logs = file_content[1]
	
	plays_timer = false
	plays_timer_toggle.button_pressed = false

	frame_slider.max_value = len(text_logs) - 1
	frame_slider.editable = true

func _on_plays_timer_toggled(toggled_on: bool) -> void:
	plays_timer = toggled_on
	if plays_timer:
		frame_slider.max_value = len(timed_text_logs) - 1
	else:
		frame_slider.max_value = len(text_logs) - 1

func _on_frame_slider_drag_started() -> void:
	if replaying:
		replaying = false
		text_box.editable = true

func _on_frame_slider_value_changed(value: float) -> void:
	if replaying:
		return

	var current_character = ''
	if plays_timer:
		current_character = timed_text_logs[value]
	else:
		current_character = text_logs[value]

	if typeof(current_character) == TYPE_STRING:
		text_box.text = current_character

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('replay'):
		replay()
