extends Node2D

@onready var text_box = $'TextEdit'
@onready var frame_slider = $'FrameSlider'
@onready var replay_button = $'Replay'
@onready var record_button = $'Record'

@onready var text_logs = []
@onready var timed_text_logs = []

@onready var replaying = false

@onready var wait_frames = 0
@onready var current_wait_frame = 0

@onready var recording = false

func replay() -> void:
	current_wait_frame = 0
	wait_frames = 0

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
		wait_frames += 1
		return
	replay_button.disabled = true
	record_button.disabled = true

	if frame_slider.value == frame_slider.max_value:
		replaying = false
		return

	var current_character = text_logs[frame_slider.value + 1]

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

func _on_frame_slider_drag_started() -> void:
	if replaying:
		replaying = false

func _on_frame_slider_value_changed(value: float) -> void:
	if replaying:
		return

	var current_character = text_logs[value]
	if typeof(current_character) == TYPE_STRING:
		text_box.text = current_character

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('replay'):
		replay()
