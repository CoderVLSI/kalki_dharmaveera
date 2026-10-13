extends Node
## Title -> campaign menu: Continue / New campaign / mission list (locked, done) / Codex / Free ride / language.

var ui: CanvasLayer
var root: Control
var list: VBoxContainer
var codex: Codex
var tile: Label


func _ready() -> void:
	Player.ensure_input()
	Sfx.refresh()
	get_tree().paused = false
	Game.mission_mode = false
	if not Game.skip_title and not Game.demo:
		var title := TitleScreen.new()
		add_child(title)
		await title.started
	Game.skip_title = true
	_build()


func _build() -> void:
	if ui:
		ui.queue_free()
	ui = CanvasLayer.new()
	ui.layer = 20
	add_child(ui)
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(root)
	Game.skin(root)
	var bg := TextureRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var vp := get_viewport().get_visible_rect().size
	bg.texture = load("res://assets/art/title_poster_portrait.jpg" if vp.y > vp.x else "res://assets/art/title_key_art.jpg")
	root.add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.82)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var box := HBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 26
	box.offset_right = -26
	box.offset_top = 20
	box.offset_bottom = -20
	box.add_theme_constant_override("separation", 26)
	root.add_child(box)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(minf(330.0, vp.x * 0.36), 0)
	left.add_theme_constant_override("separation", 10)
	box.add_child(left)
	tile = Label.new()
	tile.text = Game.t("game_title")
	tile.add_theme_font_size_override("font_size", 30)
	tile.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	tile.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(tile)
	var done := Campaign.completed.size()
	var prog := Label.new()
	prog.text = "%d / %d" % [done, Campaign.missions.size()]
	prog.modulate = Color(1, 1, 1, 0.8)
	left.add_child(prog)
	var cont := _btn(Game.t("btn_continue") if done > 0 else Game.t("btn_begin"), func(): Campaign.start(Campaign.first_incomplete()))
	cont.custom_minimum_size = Vector2(0, 70)
	left.add_child(cont)
	left.add_child(_btn(Game.t("btn_codex"), _open_codex))
	left.add_child(_btn(Game.t("btn_freeride"), func(): Campaign.start(Campaign.SANDBOX)))
	if done > 0:
		left.add_child(_btn(Game.t("btn_newgame"), func():
			Campaign.reset_progress()
			_build()))
	var langs := HBoxContainer.new()
	for code in Game.LANGS:
		var b := _btn(Game.LANGS[code], func():
			Game.set_lang(code)
			_build())
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		langs.add_child(b)
	left.add_child(langs)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(right)
	var head := Label.new()
	head.text = Game.t("missions")
	head.add_theme_font_size_override("font_size", 26)
	head.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	right.add_child(head)
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(sc)
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 6)
	sc.add_child(list)
	for m in Campaign.missions:
		var id: String = m["id"]
		var unlocked := Campaign.is_unlocked(id) or OS.get_environment("KALKI_UNLOCK") != ""
		var mark := "✓ " if Campaign.completed.has(id) else ("" if unlocked else "🔒 ")
		var b := _btn("%s%s  %s   [%s]" % [mark, id, Game.mission_title(m), m.get("tier", "")], func(): Campaign.start(id))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.disabled = not unlocked
		b.custom_minimum_size = Vector2(0, 54)
		list.add_child(b)


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 20)
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 50)
	b.pressed.connect(cb)
	return b


func _open_codex() -> void:
	codex = Codex.new()
	add_child(codex)
	codex.browse()
	await codex.closed
	codex.queue_free()
