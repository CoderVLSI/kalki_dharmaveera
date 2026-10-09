extends Node
## Verifies the Koka/Vikoka rule: a lone fallen twin revives; both down together = slain for good.

var failures := 0

func check(cond: bool, msg: String) -> void:
	print(("PASS " if cond else "FAIL ") + msg)
	if not cond:
		failures += 1


func _ready() -> void:
	Game.skip_title = true
	var main: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(0.5).timeout
	Game.dharma = 85.0
	await get_tree().create_timer(1.0).timeout
	var boss := get_tree().get_nodes_in_group("boss")
	check(boss.size() == 2, "twins spawn at dharma >= 80 (found %d)" % boss.size())
	var koka: Enemy = null
	var vikoka: Enemy = null
	for b in boss:
		if b.kind == "koka": koka = b
		else: vikoka = b
	koka.stun = 0.0
	koka.take_damage(9999.0, Vector3.ZERO, 0.0, 0.0)
	check(koka.state == "downed", "Koka falls (downed), not dead")
	check(koka.is_in_group("enemies"), "downed twin still counts as alive")
	await get_tree().create_timer(float(koka.cfg["revive_window"]) + 0.6).timeout
	check(koka.state != "downed" and koka.hp > 0.0, "lone twin revives after the window (state=%s hp=%.0f)" % [koka.state, koka.hp])
	check(Game.dharma <= 95.0 and not Game.boss_defeated, "dharma capped at 95 while twins live")
	koka.take_damage(9999.0, Vector3.ZERO, 0.0, 0.0)
	await get_tree().create_timer(0.8).timeout
	check(koka.state == "downed", "Koka down again")
	vikoka.take_damage(9999.0, Vector3.ZERO, 0.0, 0.0)
	await get_tree().create_timer(0.3).timeout
	check(koka.state == "dead" and vikoka.state == "dead", "both down together: both slain")
	check(Game.boss_defeated, "boss_defeated flag set")
	Game.add_dharma(20.0)
	check(Game.dharma >= 99.9, "dharma can now reach 100 (%.0f)" % Game.dharma)
	print("RESULT failures=%d" % failures)
	get_tree().quit(failures)
