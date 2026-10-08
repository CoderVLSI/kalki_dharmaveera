class_name Hud
extends CanvasLayer
## Code-built HUD: HP, Astra cooldown, Dharma meter with the four pillars,
## subtitles with canon tier tags, animation-test panel, end-of-run overlay.

const ANIMS := ["idle", "walk", "trot", "gallop", "slash", "rear", "victory"]

var player: Player
var hp_bar: ProgressBar
var astra_bar: ProgressBar
var dharma_bar: ProgressBar
var dharma_label: Label
var pillar_labels: Dictionary = {}
var subtitle: Label
var subtitle_tier: Label
var subtitle_panel: PanelContainer
var overlay: Label
var anim_panel: PanelContainer
var anim_title: Label
var fps_label: Label
var sub_token: int = 0


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# --- top-left: HP + Astra
	var tl := VBoxContainer.new()
	tl.position = Vector2(20, 16)
	tl.custom_minimum_size = Vector2(300, 0)
	root.add_child(tl)
	tl.add_child(_title("KALKI"))
	hp_bar = _bar(Color(0.85, 0.15, 0.15), 300, 22)
	tl.add_child(hp_bar)
	var al := _title("ASTRA  (F)")
	al.add_theme_font_size_override("font_size", 13)
	tl.add_child(al)
	astra_bar = _bar(Color(0.95, 0.78, 0.25), 300, 12)
	tl.add_child(astra_bar)

	# --- top-center: dharma
	var tc := VBoxContainer.new()
	tc.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tc.position = Vector2(-260, 14)
	tc.custom_minimum_size = Vector2(520, 0)
	tc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tc)
	dharma_label = _title("DHARMA 0%")
	dharma_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tc.add_child(dharma_label)
	dharma_bar = _bar(Color(0.98, 0.8, 0.2), 520, 22)
	tc.add_child(dharma_bar)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	tc.add_child(row)
	for p in Game.world_cfg.get("pillars", []):
		var l := Label.new()
		l.text = "%s (%d)" % [p["name"], int(p["threshold"])]
		l.add_theme_font_size_override("font_size", 14)
		l.modulate = Color(0.5, 0.5, 0.5)
		row.add_child(l)
		pillar_labels[p["id"]] = l

	# --- top-right: animation test
	anim_panel = PanelContainer.new()
	anim_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	anim_panel.position = Vector2(-190, 14)
	anim_panel.custom_minimum_size = Vector2(176, 0)
	root.add_child(anim_panel)
	var av := VBoxContainer.new()
	anim_panel.add_child(av)
	anim_title = _title("ANIMATION TEST  (T)")
	anim_title.add_theme_font_size_override("font_size", 13)
	av.add_child(anim_title)
	for a in ANIMS:
		var b := Button.new()
		b.text = a.capitalize()
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func(): if player: player.test_play(a))
		av.add_child(b)
	var free := Button.new()
	free.text = "Back to play"
	free.focus_mode = Control.FOCUS_NONE
	free.pressed.connect(func(): if player: player.set_anim_test(false))
	av.add_child(free)

	# --- bottom: subtitle
	subtitle_panel = PanelContainer.new()
	subtitle_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	subtitle_panel.position = Vector2(-440, -150)
	subtitle_panel.custom_minimum_size = Vector2(880, 0)
	subtitle_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	subtitle_panel.visible = false
	root.add_child(subtitle_panel)
	var sv := VBoxContainer.new()
	subtitle_panel.add_child(sv)
	subtitle = Label.new()
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 20)
	sv.add_child(subtitle)
	subtitle_tier = Label.new()
	subtitle_tier.add_theme_font_size_override("font_size", 12)
	subtitle_tier.modulate = Color(0.8, 0.8, 0.6, 0.8)
	sv.add_child(subtitle_tier)

	# --- bottom-left: controls
	var help := Label.new()
	help.text = "WASD move  ·  Shift gallop  ·  Ctrl walk  ·  LMB/J slash  ·  F astra (rear-up)  ·  Space dash  ·  Q/E or RMB-drag camera  ·  wheel zoom  ·  T anim test  ·  R restart"
	help.add_theme_font_size_override("font_size", 12)
	help.modulate = Color(1, 1, 1, 0.75)
	help.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help.position = Vector2(16, -28)
	help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(help)

	fps_label = Label.new()
	fps_label.add_theme_font_size_override("font_size", 12)
	fps_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	fps_label.position = Vector2(-90, -28)
	fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(fps_label)

	overlay = Label.new()
	overlay.set_anchors_preset(Control.PRESET_CENTER)
	overlay.position = Vector2(-420, -80)
	overlay.custom_minimum_size = Vector2(840, 0)
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.add_theme_font_size_override("font_size", 40)
	overlay.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	overlay.add_theme_constant_override("outline_size", 10)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)

	Game.dharma_changed.connect(_on_dharma)
	Game.player_hp_changed.connect(_on_hp)
	Game.message.connect(_on_message)
	Game.pillar_restored.connect(_on_pillar)
	Game.victory.connect(_on_victory)
	Game.player_died.connect(_on_died)
	if player:
		_on_hp(player.hp, player.max_hp)
	_on_dharma(Game.dharma)
	dharma_bar.value = Game.dharma


func _title(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 5)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _bar(col: Color, w: float, h: float) -> ProgressBar:
	var b := ProgressBar.new()
	b.custom_minimum_size = Vector2(w, h)
	b.show_percentage = false
	b.max_value = 100.0
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = col
	fill.set_corner_radius_all(4)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.55)
	bg.set_corner_radius_all(4)
	b.add_theme_stylebox_override("fill", fill)
	b.add_theme_stylebox_override("background", bg)
	return b


func _process(_delta: float) -> void:
	fps_label.text = "%d fps" % Engine.get_frames_per_second()
	if player:
		astra_bar.value = 100.0 * (1.0 - player.special_cd / player.special_cd_max)
		anim_title.text = "ANIMATION TEST  (T)%s" % ("  ON: " + player.test_name if player.anim_test else "")
		anim_title.modulate = Color(1, 0.9, 0.4) if player.anim_test else Color(1, 1, 1)


func _on_dharma(v: float) -> void:
	var tw := create_tween()
	tw.tween_property(dharma_bar, "value", v, 0.5)
	dharma_label.text = "DHARMA %d%%" % int(v)


func _on_hp(hp: float, max_hp: float) -> void:
	hp_bar.value = hp / max_hp * 100.0


func _on_pillar(id: String) -> void:
	var l: Label = pillar_labels.get(id)
	if l:
		l.modulate = Color(1.0, 0.85, 0.3)
		l.text = "✦ " + l.text


func _on_message(speaker: String, text: String, tier: String) -> void:
	sub_token += 1
	var token := sub_token
	subtitle.text = "%s:  %s" % [speaker, text]
	subtitle_tier.text = "[%s]" % tier
	subtitle_panel.visible = true
	await get_tree().create_timer(6.5).timeout
	if token == sub_token:
		subtitle_panel.visible = false


func _on_victory() -> void:
	await get_tree().create_timer(1.5).timeout
	overlay.text = "SATYA YUGA\nDharma stands on all four legs.\n\nPress R to ride again"
	overlay.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4))
	overlay.visible = true


func _on_died() -> void:
	overlay.text = "Kali's age endures...\n\nPress R to rise again"
	overlay.add_theme_color_override("font_color", Color(0.95, 0.4, 0.35))
	overlay.visible = true
