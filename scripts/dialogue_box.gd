class_name DialogueBox
extends CanvasLayer
## Plays a sequence of dialogue lines (data/dialogue.json) with speaker, localized text and the
## source tier tag, pausing the game. Tap / Enter / Space / click advances, Esc skips the rest.
## `await box.play(["line_a", "line_b"])`, or `await box.choose(prompt_id, options)` for a choice.

signal finished
signal chosen(index: int)

var _panel: PanelContainer
var _speaker: Label
var _text: Label
var _tier: Label
var _hint: Label
var _choices: VBoxContainer
var _queue: Array = []
var _active: bool = false
var _waiting: bool = false
var _typing: bool = false
var _tw: Tween


func _ready() -> void:
	layer = 70
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	Game.skin(root)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	var vp := get_viewport().get_visible_rect().size
	var w := minf(980.0, vp.x - 40.0)
	_panel.custom_minimum_size = Vector2(w, 0)
	_panel.position = Vector2(-w / 2.0, -230)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.04, 0.08, 0.86)
	sb.border_color = Color(0.9, 0.72, 0.3, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(14)
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.visible = false
	root.add_child(_panel)
	var v := VBoxContainer.new()
	_panel.add_child(v)
	_speaker = Label.new()
	_speaker.add_theme_font_size_override("font_size", 22)
	_speaker.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38))
	v.add_child(_speaker)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", 24)
	_text.custom_minimum_size = Vector2(w - 40.0, 0)
	v.add_child(_text)
	_choices = VBoxContainer.new()
	v.add_child(_choices)
	var row := HBoxContainer.new()
	v.add_child(row)
	_tier = Label.new()
	_tier.add_theme_font_size_override("font_size", 12)
	_tier.modulate = Color(0.8, 0.8, 0.6, 0.85)
	_tier.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_tier)
	_hint = Label.new()
	_hint.text = "▶"
	_hint.add_theme_font_size_override("font_size", 20)
	_hint.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38))
	row.add_child(_hint)
	var blink := create_tween().set_loops()
	blink.tween_property(_hint, "modulate:a", 0.25, 0.6)
	blink.tween_property(_hint, "modulate:a", 1.0, 0.6)


func is_active() -> bool:
	return _active


func play(lines: Array) -> void:
	if lines.is_empty():
		return
	_queue = lines.duplicate()
	_active = true
	get_tree().paused = true
	_panel.visible = true
	while not _queue.is_empty():
		await _show(str(_queue.pop_front()))
	_panel.visible = false
	_active = false
	get_tree().paused = false
	finished.emit()


func _show(id: String) -> void:
	var line: Dictionary = Game.dialogue.get(id, {})
	if line.is_empty():
		push_warning("dialogue line missing: " + id)
		return
	_speaker.text = Game.speaker_name(line)
	_text.text = Game.line_text(line)
	_tier.text = "[%s]" % Game.tier_label(line)
	_choices.visible = false
	_hint.visible = true
	Game.voice_line.emit(id)
	# typewriter reveal, then wait for the player
	_text.visible_ratio = 0.0
	_typing = true
	if _tw:
		_tw.kill()
	_tw = create_tween()
	_tw.tween_property(_text, "visible_ratio", 1.0, clampf(float(_text.text.length()) * 0.018, 0.4, 2.2))
	_tw.tween_callback(func(): _typing = false)
	_waiting = true
	if Campaign.autoplay:
		get_tree().create_timer(0.02).timeout.connect(func(): chosen.emit(-1))
	await chosen
	_waiting = false


func choose(prompt_id: String, options: Array) -> int:
	## options: [{"text": "string key or literal", ...}] -> returns the picked index
	_active = true
	get_tree().paused = true
	_panel.visible = true
	var line: Dictionary = Game.dialogue.get(prompt_id, {})
	_speaker.text = Game.speaker_name(line)
	_text.text = Game.line_text(line)
	_text.visible_ratio = 1.0
	_tier.text = "[%s]" % Game.tier_label(line)
	_hint.visible = false
	for c in _choices.get_children():
		c.queue_free()
	_choices.visible = true
	_waiting = false
	var picked := [-1]
	for i in options.size():
		var b := Button.new()
		b.text = Game.t(str(options[i].get("text", "")))
		b.add_theme_font_size_override("font_size", 22)
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, 52)
		b.pressed.connect(func(): picked[0] = i; chosen.emit(i))
		_choices.add_child(b)
	if Campaign.autoplay:
		var ci := 0
		for oi in options.size():
			if bool(options[oi].get("correct", false)):
				ci = oi
		get_tree().create_timer(0.02).timeout.connect(func(): picked[0] = ci; chosen.emit(ci))
	await chosen
	_choices.visible = false
	for c in _choices.get_children():
		c.queue_free()
	_panel.visible = false
	_active = false
	get_tree().paused = false
	return picked[0]


func _unhandled_input(event: InputEvent) -> void:
	if not _active or not _waiting:
		return
	var adv := false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			_queue.clear()
			_text.visible_ratio = 1.0
			adv = true
		else:
			adv = event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_G, KEY_E]
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		adv = true
	elif event is InputEventScreenTouch and event.pressed:
		adv = true
	if not adv:
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_typing = false
		if _tw:
			_tw.kill()
		_text.visible_ratio = 1.0
		return
	chosen.emit(-1)
