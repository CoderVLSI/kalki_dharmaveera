extends Node
## Visual capture helper: plays the prologue (use with --write-movie).
func _ready() -> void:
	var p := Prologue.new()
	add_child(p)
	await p.finished
	get_tree().quit()
