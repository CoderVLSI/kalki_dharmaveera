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
