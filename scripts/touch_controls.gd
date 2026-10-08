class_name TouchControls
extends CanvasLayer
## On-screen controls for phones: floating move stick (left), camera drag (right),
## action buttons (SLASH / ASTRA / DASH / RUN). Feeds the same InputMap actions as the keyboard.

signal camera_drag(relative: Vector2)

const STICK_R := 90.0
const BTN := {
	"attack":  {"label": "SLASH", "col": Color(0.95, 0.75, 0.25), "r": 62.0},
	"special": {"label": "ASTRA", "col": Color(0.55, 0.8, 1.0),   "r": 46.0},
	"dash":    {"label": "DASH",  "col": Color(0.7, 1.0, 0.6),    "r": 42.0},
	"gallop":  {"label": "RUN",   "col": Color(1.0, 0.6, 0.4),    "r": 42.0},
}

var canvas: Control
var stick_id: int = -1
var stick_origin: Vector2
var stick_pos: Vector2
var cam_id: int = -1
var btn_ids: Dictionary = {}     # touch index -> action
var gallop_on: bool = false


func _ready() -> void:
	layer = 50
	canvas = Control.new()
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.draw.connect(_draw_ui)
	add_child(canvas)


func _btn_center(action: String) -> Vector2:
	var s := get_viewport().get_visible_rect().size
	match action:
		"attack": return Vector2(s.x - 130, s.y - 150)
		"special": return Vector2(s.x - 270, s.y - 90)
		"dash": return Vector2(s.x - 110, s.y - 300)
		"gallop": return Vector2(s.x - 270, s.y - 230)
	return Vector2.ZERO


func _btn_at(p: Vector2) -> String:
	for a in BTN:
		if p.distance_to(_btn_center(a)) <= float(BTN[a]["r"]) + 12.0:
			return a
	return ""


func _input(event: InputEvent) -> void:
	var s := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch
		if t.pressed:
			var a := _btn_at(t.position)
			if a != "":
				btn_ids[t.index] = a
				_press(a)
			elif t.position.x < s.x * 0.4 and stick_id == -1:
				stick_id = t.index
				stick_origin = t.position
				stick_pos = t.position
			elif cam_id == -1 and t.position.x >= s.x * 0.4:
				cam_id = t.index
		else:
			if btn_ids.has(t.index):
				_release(btn_ids[t.index])
				btn_ids.erase(t.index)
			if t.index == stick_id:
				stick_id = -1
				_set_move(Vector2.ZERO)
			if t.index == cam_id:
				cam_id = -1
		canvas.queue_redraw()
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.index == stick_id:
			stick_pos = d.position
			var v := (stick_pos - stick_origin) / STICK_R
			if v.length() > 1.0:
				v = v.normalized()
				stick_origin = stick_pos - v * STICK_R
			_set_move(v)
		elif d.index == cam_id:
			camera_drag.emit(d.relative)
		canvas.queue_redraw()


func _press(a: String) -> void:
	if a == "gallop":
		gallop_on = not gallop_on
		if gallop_on:
			Input.action_press("gallop")
		else:
			Input.action_release("gallop")
	else:
		Input.action_press(a)


func _release(a: String) -> void:
	if a != "gallop":
		Input.action_release(a)


func _set_move(v: Vector2) -> void:
	var dead := 0.15
	for n in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(n)
	if v.length() < dead:
		return
	if v.x < 0.0:
		Input.action_press("move_left", -v.x)
	else:
		Input.action_press("move_right", v.x)
	if v.y < 0.0:
		Input.action_press("move_forward", -v.y)
	else:
		Input.action_press("move_back", v.y)


func _draw_ui() -> void:
	if stick_id != -1:
		canvas.draw_circle(stick_origin, STICK_R, Color(1, 1, 1, 0.12))
		canvas.draw_arc(stick_origin, STICK_R, 0, TAU, 48, Color(1, 1, 1, 0.5), 3.0)
		canvas.draw_circle(stick_pos, 34.0, Color(1, 0.9, 0.5, 0.55))
	else:
		var s := get_viewport().get_visible_rect().size
		var hint := Vector2(150, s.y - 150)
		canvas.draw_arc(hint, STICK_R, 0, TAU, 48, Color(1, 1, 1, 0.22), 3.0)
	var font := ThemeDB.fallback_font
	for a in BTN:
		var c := _btn_center(a)
		var col: Color = BTN[a]["col"]
		var on: bool = btn_ids.values().has(a) or (a == "gallop" and gallop_on)
		canvas.draw_circle(c, float(BTN[a]["r"]), Color(col.r, col.g, col.b, 0.55 if on else 0.28))
		canvas.draw_arc(c, float(BTN[a]["r"]), 0, TAU, 40, Color(col.r, col.g, col.b, 0.9), 3.0)
		var txt: String = BTN[a]["label"]
		var sz := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		canvas.draw_string(font, c - Vector2(sz.x * 0.5, -5), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.95))
