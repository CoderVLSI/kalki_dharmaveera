extends Node
## Audio manager (autoload "Sfx"): SFX pool, voice lines, and two ambience layers
## (Kali drone + war-drum  <->  Satya tanpura + bells) crossfaded by Dharma.
## All audio is pre-generated: tools/audio/make_sfx.py (free) and gen_voice.py (ElevenLabs).

const SFX_NAMES := ["swish", "hit", "die", "hoof", "dash", "boom", "hurt", "twang", "chime", "fanfare", "click"]
const VOICE_DIR := "res://assets/audio/voice/%s.mp3"

var streams: Dictionary = {}
var pool: Array[AudioStreamPlayer] = []
var voice_player: AudioStreamPlayer
var kali: AudioStreamPlayer
var satya: AudioStreamPlayer
var muted: bool = false
var _tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for n in SFX_NAMES:
		streams[n] = load("res://assets/audio/sfx/%s.ogg" % n)
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	voice_player = AudioStreamPlayer.new()
	voice_player.volume_db = 0.0
	add_child(voice_player)
	kali = _loop("res://assets/audio/music/kali_loop.ogg", -9.0)
	satya = _loop("res://assets/audio/music/satya_loop.ogg", -60.0)
	Game.voice_line.connect(_on_voice)
	Game.dharma_changed.connect(func(_v: float): _crossfade(1.5))
	Game.pillar_restored.connect(func(_id: String): play("chime", -4.0))
	Game.victory.connect(func(): play("fanfare", -5.0))
	refresh()


func _loop(path: String, db: float) -> AudioStreamPlayer:
	var s: AudioStreamOggVorbis = load(path)
	s.loop = true
	var p := AudioStreamPlayer.new()
	p.stream = s
	p.volume_db = db
	add_child(p)
	p.play()
	return p


func _targets() -> Vector2:
	var t := smoothstep(0.0, 100.0, Game.dharma)
	return Vector2(lerpf(-9.0, -45.0, t), lerpf(-40.0, -8.0, t))


func refresh() -> void:
	var v := _targets()
	kali.volume_db = v.x
	satya.volume_db = v.y


func _crossfade(dur: float) -> void:
	var v := _targets()
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(kali, "volume_db", v.x, dur)
	_tween.tween_property(satya, "volume_db", v.y, dur)


func play(sfx_name: String, vol_db: float = 0.0, pitch_var: float = 0.07) -> void:
	if not streams.has(sfx_name):
		return
	var chosen: AudioStreamPlayer = pool[0]
	for p in pool:
		if not p.playing:
			chosen = p
			break
	chosen.stream = streams[sfx_name]
	chosen.volume_db = vol_db
	chosen.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
	chosen.play()


func _on_voice(line_id: String) -> void:
	var path := VOICE_DIR % line_id
	if not ResourceLoader.exists(path):
		return
	voice_player.stream = load(path)
	voice_player.play()


func set_muted(m: bool) -> void:
	muted = m
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), m)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		set_muted(not muted)
