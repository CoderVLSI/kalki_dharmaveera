extends Node
## Global game state + rule tables loaded from res://data/*.json.
## Signals keep gameplay, world presentation and HUD decoupled.

signal dharma_changed(value: float)
signal player_hp_changed(hp: float, max_hp: float)
signal message(speaker: String, text: String, tier: String)
signal pillar_restored(id: String)
signal enemy_killed(kind: String)
signal victory
signal voice_line(line_id: String)
signal player_died
signal lang_changed

var enemies_cfg: Dictionary = {}
var world_cfg: Dictionary = {}
var dialogue: Dictionary = {}
var strings: Dictionary = {}
const LANGS := {"en": "English", "hi": "हिन्दी", "te": "తెలుగు"}
const SETTINGS := "user://settings.cfg"
var lang: String = "en"
var _fonts: Dictionary = {}

var dharma: float = 0.0
var kills: int = 0
var finished: bool = false
var boss_defeated: bool = false
var restored: Array = []
var demo: bool = false
var last_said: Dictionary = {}
const MIN_GAP := {"player_hurt": 12.0, "banner_down": 5.0, "boss_down": 8.0}
var skip_title: bool = false   # set on restart so the title only shows once


func _ready() -> void:
	enemies_cfg = _load_json("res://data/enemies.json")
	world_cfg = _load_json("res://data/world.json")
	dialogue = _load_json("res://data/dialogue.json")
	strings = _load_json("res://data/strings.json")
	_init_lang()
	demo = OS.get_environment("KALKI_DEMO") != ""


## Language: saved choice, else the device language if we have it, else English.
func _init_lang() -> void:
	var cf := ConfigFile.new()
	var want := OS.get_locale_language()
	if cf.load(SETTINGS) == OK:
		want = str(cf.get_value("game", "lang", want))
	if OS.get_environment("KALKI_LANG") != "":   # test hook: KALKI_LANG=hi|te|en
		want = OS.get_environment("KALKI_LANG")
	lang = want if LANGS.has(want) else "en"
	_apply_font()


func set_lang(code: String) -> void:
	if not LANGS.has(code) or code == lang:
		return
	lang = code
	var cf := ConfigFile.new()
	cf.load(SETTINGS)
	cf.set_value("game", "lang", code)
	cf.save(SETTINGS)
	_apply_font()
	lang_changed.emit()


## Hindi/Telugu need Noto fonts (the built-in UI font has no Devanagari/Telugu glyphs). One font
## per language, with the built-in font only as the Latin fallback: mixing the two Indic fonts
## in one fallback chain breaks conjunct shaping.
func ui_font() -> Font:
	if lang == "en":
		return null
	if _fonts.has(lang):
		return _fonts[lang]
	var f := FontFile.new()
	f.load_dynamic_font("res://assets/fonts/%s-Regular.ttf" % ("NotoSansDevanagari" if lang == "hi" else "NotoSansTelugu"))
	f.fallbacks = [ThemeDB.fallback_font]
	_fonts[lang] = f
	return f


## A CanvasLayer stops theme inheritance, so every UI root Control calls Game.skin(self).
func skin(c: Control) -> void:
	var th: Theme = null
	if lang != "en":
		th = Theme.new()
		th.default_font = ui_font()
	c.theme = th


func _apply_font() -> void:
	pass   # fonts are applied per UI root via skin()


func t(key: String) -> String:
	var e: Dictionary = strings.get(key, {})
	return str(e.get(lang, e.get("en", key)))


func line_text(line: Dictionary) -> String:
	return str(line.get("text_" + lang, line.get("text", "")))


func speaker_name(line: Dictionary) -> String:
	var k := "speaker_" + str(line.get("speaker", ""))
	return t(k) if strings.has(k) else str(line.get("speaker", ""))


func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Missing data file " + path)
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Dictionary else {}


func reset() -> void:
	dharma = 0.0
	kills = 0
	finished = false
	boss_defeated = false
	restored.clear()
	# debug hook for screenshots: KALKI_DHARMA=100 previews the Satya Yuga world
	var preset := OS.get_environment("KALKI_DHARMA")
	if preset != "":
		dharma = clampf(float(preset), 0.0, 100.0)


func add_dharma(amount: float) -> void:
	if finished:
		return
	# Satya cannot be fully restored while Kali's twin generals still stand.
	dharma = clampf(dharma + amount, 0.0, 100.0 if boss_defeated else 95.0)
	dharma_changed.emit(dharma)
	for p in world_cfg.get("pillars", []):
		if dharma >= float(p["threshold"]) and not restored.has(p["id"]):
			restored.append(p["id"])
			pillar_restored.emit(p["id"])
			say(p["line"])
	if dharma >= 100.0:
		finished = true
		say("victory")
		victory.emit()


## Subtitle tag per the reference protocol: source tier (A/B/G) plus an explicit adapted-dialogue mark.
func tier_label(line: Dictionary) -> String:
	if line.get("speech_type", "") == "DRAMATIZED_ADAPTATION":
		return "%s · %s" % [line.get("source_tier", line.get("tier", "")), t("adapted")]
	return str(line.get("source_tier", line.get("tier", "")))


func say(line_id: String) -> void:
	var line: Dictionary = dialogue.get(line_id, {})
	if line.is_empty():
		return
	var now := Time.get_ticks_msec() / 1000.0
	if MIN_GAP.has(line_id) and now - float(last_said.get(line_id, -999.0)) < float(MIN_GAP[line_id]):
		return
	last_said[line_id] = now
	message.emit(speaker_name(line), line_text(line), tier_label(line))
	voice_line.emit(line_id)
