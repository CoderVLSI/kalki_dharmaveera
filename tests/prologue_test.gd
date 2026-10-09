extends Node
## The prologue builds, plays its three voiced beats, and can be skipped. RESULT failures=0.
var failures := 0
func check(c: bool, m: String) -> void:
	print(("PASS " if c else "FAIL ") + m)
	if not c: failures += 1

func _ready() -> void:
	for id in Prologue.LINES:
		check(Game.dialogue.has(id) and ResourceLoader.exists(Sfx.VOICE_DIR % id), "line + voice for " + id)
	check(Props.character("nonexistent_slot", 1.8) == null, "empty character slot falls back to null")
	check(Props.parts("tree_dead").size() > 0 and Props.parts("tree_alive").size() > 0, "tree models load")
	for id in Game.dialogue:
		if not id.begins_with("_"):
			var l: Dictionary = Game.dialogue[id]
			check(l.has("source_tier") and l.has("speech_type") and l.has("locator"), "dialogue %s carries source_tier/speech_type/locator" % id)
	for f in ["missions", "characters"]:
		check(not Game._load_json("res://data/%s.json" % f).is_empty(), "data/%s.json loads" % f)
	check(Game._load_json("res://data/missions.json")["missions"].size() == 18, "18 missions M00-M17")
	for slot in ["shiva", "brahma"]:
		var c := Props.character(slot, 2.0)
		add_child(c)
		var aps := c.find_children("*", "AnimationPlayer", true, false)
		check(aps.size() > 0 and (aps[0] as AnimationPlayer).has_animation("idle") and (aps[0] as AnimationPlayer).has_animation("walk") and (aps[0] as AnimationPlayer).has_animation("bless"), "%s is rigged (idle/walk/bless)" % slot)
		c.queue_free()
	var sh := Companion.new()
	add_child(sh)
	await get_tree().process_frame
	check(sh.model != null and sh.anim != null, "Shuka companion loads and animates")
	sh.queue_free()
	var p := Prologue.new()
	add_child(p)
	var done := [false]
	p.finished.connect(func(): done[0] = true)
	await get_tree().create_timer(3.0).timeout
	check(not done[0], "still playing after 3 s")
	check(p._sub.text.begins_with("Brahma") or p._sub.text.begins_with("Narayana"), "subtitle shows (%s)" % p._sub.text.left(24))
	p._finish()
	await get_tree().create_timer(1.2).timeout
	check(done[0], "skip ends the prologue")
	print("RESULT failures=%d" % failures)
	get_tree().quit(failures)
