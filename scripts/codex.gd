class_name Codex
extends CanvasLayer
## In-game codex: lore entries with the source tier and locator from the reference PDF.
## show_entry(id) shows one entry with a Close button (a mission objective); browse() lists every
## entry the player has met (opened from the campaign menu).

signal closed

var entries: Dictionary = {}
var order: Array = []
var _list: VBoxContainer
var _title: Label
var _tier: Label
var _body: Label
var _root: Control


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	var d: Dictionary = Game._load_json("res://data/codex.json")
	for e in d.get("entries", []):
		entries[e["id"]] = e
		order.append(e["id"])
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	Game.skin(_root)
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.05, 0.94)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(bg)
	var vp := get_viewport().get_visible_rect().size
	var box := HBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 30
	box.offset_right = -30
	box.offset_top = 24
	box.offset_bottom = -24
	box.add_theme_constant_override("separation", 22)
	_root.add_child(box)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(minf(300.0, vp.x * 0.3), 0)
	box.add_child(left)
	var head := Label.new()
	head.text = Game.t("codex")
	head.add_theme_font_size_override("font_size", 28)
	head.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38))
	left.add_child(head)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(sc)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(_list)
	var close := Button.new()
	close.text = Game.t("btn_close")
	close.custom_minimum_size = Vector2(0, 56)
	close.add_theme_font_size_override("font_size", 22)
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(func(): closed.emit())
	left.add_child(close)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(right)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_title)
	_tier = Label.new()
	_tier.add_theme_font_size_override("font_size", 14)
	_tier.modulate = Color(0.8, 0.8, 0.6, 0.9)
	_tier.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_tier)
	var rs := ScrollContainer.new()
	rs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(rs)
	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.custom_minimum_size = Vector2(vp.x - 440.0, 0)
	_body.add_theme_font_size_override("font_size", 22)
	rs.add_child(_body)


func _field(e: Dictionary, k: String) -> String:
	return str(e.get(k + "_" + Game.lang, e.get(k, "")))


func _show(id: String) -> void:
	var e: Dictionary = entries.get(id, {})
	if e.is_empty():
		return
	_title.text = _field(e, "title")
	_tier.text = "[%s · %s]  %s" % [e.get("tier", "G"), e.get("source", ""), Game.t("adapted_note") if bool(e.get("adapted", true)) else ""]
	_body.text = _field(e, "text")


func show_entry(id: String) -> void:
	if Campaign.autoplay:
		get_tree().create_timer(0.05).timeout.connect(func(): closed.emit())
	for c in _list.get_children():
		c.queue_free()
	_show(id)


func browse() -> void:
	for c in _list.get_children():
		c.queue_free()
	var first := ""
	for id in order:
		if not Campaign.codex_seen.has(id):
			continue
		var b := Button.new()
		b.text = _field(entries[id], "title")
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 18)
		b.custom_minimum_size = Vector2(0, 46)
		b.pressed.connect(func(): _show(id))
		_list.add_child(b)
		if first == "":
			first = id
	if first == "":
		_body.text = Game.t("codex_empty")
		_title.text = ""
		_tier.text = ""
	else:
		_show(first)
