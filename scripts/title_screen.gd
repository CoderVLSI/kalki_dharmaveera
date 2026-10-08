class_name TitleScreen
extends CanvasLayer
## Full-screen title: landscape key art on wide windows, portrait poster on tall ones.

signal started

var _done: bool = false
var _root: Control


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	_root = root
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var tex := TextureRect.new()
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	root.add_child(tex)
	var vp := get_viewport().get_visible_rect().size
	var path := "res://assets/art/title_poster_portrait.jpg" if vp.y > vp.x else "res://assets/art/title_key_art.jpg"
	tex.texture = load(path)

	var hint := Button.new()
	hint.text = "RIDE OUT"
	hint.add_theme_font_size_override("font_size", 30)
	hint.custom_minimum_size = Vector2(260, 64)
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.position = Vector2(-130, -190 if vp.x > vp.y else -130)
	hint.focus_mode = Control.FOCUS_NONE
	hint.pressed.connect(_start)
	root.add_child(hint)
	var tw := create_tween().set_loops()
	tw.tween_property(hint, "modulate:a", 0.55, 0.9)
	tw.tween_property(hint, "modulate:a", 1.0, 0.9)
	var sub := Label.new()
	sub.text = "Prototype v0.1  ·  Enter / Space / click"
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	sub.add_theme_constant_override("outline_size", 6)
	sub.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	sub.position = Vector2(-120, -108 if vp.x > vp.y else -62)
	root.add_child(sub)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			_start()


func _start() -> void:
	if _done:
		return
	_done = true
	var tw := create_tween()
	tw.tween_property(_root, "modulate:a", 0.0, 0.6)
	await tw.finished
	started.emit()
	queue_free()
