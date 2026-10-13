extends Node
## Runs every mission M00..M17 on autopilot (KALKI_AUTOPLAY) and checks it completes. RESULT failures=0.
var failures := 0
func check(c: bool, m: String) -> void:
	print(("PASS " if c else "FAIL ") + m)
	if not c: failures += 1

func _ready() -> void:
	Campaign.autoplay = true
	Engine.time_scale = 4.0
	check(Campaign.missions.size() == 18, "18 missions")
	var only := OS.get_environment("KALKI_ONLY")
	for m in Campaign.missions:
		var id: String = m["id"]
		if only != "" and only != id:
			continue
		check(Campaign.play_block(id).size() > 0, id + " has a play block")
		check(m.get("title_hi", "") != "" and m.get("title_te", "") != "", id + " has hi/te titles")
		Campaign.current = id
		Game.reset()
		get_tree().paused = false
		var main: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
		add_child(main)
		var t := 0.0
		while t < 90.0 and not main.mission_done:
			await get_tree().create_timer(0.25).timeout
			t += 0.25
		check(main.mission_done, "%s completes on autopilot (%.0fs of scaled time)" % [id, t])
		main.queue_free()
		get_tree().paused = false
		await get_tree().process_frame
		await get_tree().process_frame
	print("RESULT failures=%d" % failures)
	get_tree().quit(1 if failures > 0 else 0)
