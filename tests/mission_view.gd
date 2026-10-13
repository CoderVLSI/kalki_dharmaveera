extends Node
## Visual helper: KALKI_MISSION=M03 renders that mission after a few seconds into $KALKI_SHOT (png), then quits.
func _ready() -> void:
	Campaign.current = OS.get_environment("KALKI_MISSION")
	Game.skip_title = true
	var main: Node = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	add_child(main)
	await get_tree().create_timer(float(OS.get_environment("KALKI_WAIT") if OS.get_environment("KALKI_WAIT") != "" else "6")).timeout
	get_viewport().get_texture().get_image().save_png(OS.get_environment("KALKI_SHOT"))
	get_tree().quit()
