extends Node
## Campaign state (autoload "Campaign"): mission data, progress, flags, save file.
## Missions M00..M17 follow docs/sources/Kalki_Purana_Game_Reference.pdf; "SANDBOX" is the old
## arena (kept for tests and free play).

signal mission_completed(id: String)

const SAVE := "user://save.cfg"
const SANDBOX := "SANDBOX"

var missions: Array = []
var by_id: Dictionary = {}
var current: String = SANDBOX
var completed: Array = []
var flags: Dictionary = {}     # has_sword, has_horse, has_shuka, ally_shashidhvaja, boons...
var codex_seen: Array = []
var autoplay: bool = OS.get_environment("KALKI_AUTOPLAY") != ""   # test hook: auto-advance everything


func _ready() -> void:
	var d: Dictionary = Game._load_json("res://data/missions.json")
	missions = d.get("missions", [])
	for m in missions:
		by_id[m["id"]] = m
	load_progress()


func mission(id: String) -> Dictionary:
	return by_id.get(id, {})


func play_block(id: String) -> Dictionary:
	return mission(id).get("play", {})


func index_of(id: String) -> int:
	for i in missions.size():
		if missions[i]["id"] == id:
			return i
	return -1


func next_id(id: String) -> String:
	var i := index_of(id)
	return missions[i + 1]["id"] if i >= 0 and i + 1 < missions.size() else ""


func is_unlocked(id: String) -> bool:
	var i := index_of(id)
	if i <= 0:
		return true
	return completed.has(missions[i - 1]["id"]) or completed.has(id)


func has_flag(f: String) -> bool:
	return bool(flags.get(f, false))


func set_flag(f: String, v: Variant = true) -> void:
	flags[f] = v
	save_progress()


func start(id: String) -> void:
	current = id
	Game.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func complete(id: String) -> void:
	if id == SANDBOX:
		return
	if not completed.has(id):
		completed.append(id)
	save_progress()
	mission_completed.emit(id)


func first_incomplete() -> String:
	for m in missions:
		if not completed.has(m["id"]):
			return m["id"]
	return missions[0]["id"] if missions.size() > 0 else SANDBOX


func mark_codex(entry: String) -> void:
	if not codex_seen.has(entry):
		codex_seen.append(entry)
		save_progress()


func save_progress() -> void:
	var cf := ConfigFile.new()
	cf.load(SAVE)
	cf.set_value("campaign", "completed", completed)
	cf.set_value("campaign", "flags", flags)
	cf.set_value("campaign", "codex", codex_seen)
	cf.save(SAVE)


func load_progress() -> void:
	var cf := ConfigFile.new()
	if cf.load(SAVE) != OK:
		return
	completed = cf.get_value("campaign", "completed", [])
	flags = cf.get_value("campaign", "flags", {})
	codex_seen = cf.get_value("campaign", "codex", [])


func reset_progress() -> void:
	completed.clear()
	flags.clear()
	codex_seen.clear()
	save_progress()
