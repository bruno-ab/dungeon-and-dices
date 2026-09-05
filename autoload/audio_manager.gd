extends Node

## AudioManager — BGM/BGS/ME/SFX com pool e crossfade.

const BUS_MASTER := &"Master"
const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"
const BUS_UI := &"UI"

const PATH_BGM := "res://assets/audio/bgm/%s.ogg"
const PATH_SE := "res://assets/audio/se/%s.ogg"
const PATH_ME := "res://assets/audio/me/%s.ogg"
const PATH_BGS := "res://assets/audio/bgs/%s.ogg"

const POOL_SIZE := 12

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_active: AudioStreamPlayer
var _bgs: AudioStreamPlayer
var _me: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _ui_pool: Array[AudioStreamPlayer] = []
var _current_bgm: String = ""
var _cache: Dictionary = {} ## path -> AudioStream


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_buses()
	_music_a = _make_player(BUS_MUSIC, "MusicA")
	_music_b = _make_player(BUS_MUSIC, "MusicB")
	_music_active = _music_a
	_bgs = _make_player(BUS_MUSIC, "BGS")
	_me = _make_player(BUS_SFX, "ME")
	for i in POOL_SIZE:
		_sfx_pool.append(_make_player(BUS_SFX, "SFX_%d" % i))
		_ui_pool.append(_make_player(BUS_UI, "UI_%d" % i))


func _ensure_buses() -> void:
	_add_bus_if_missing("Music")
	_add_bus_if_missing("SFX")
	_add_bus_if_missing("UI")
	# volumes padrão (suaves)
	_set_bus_db("Music", -4.0)
	_set_bus_db("SFX", -2.0)
	_set_bus_db("UI", -6.0)


func _add_bus_if_missing(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")


func _set_bus_db(bus_name: String, db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)


func _make_player(bus: StringName, node_name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = node_name
	p.bus = String(bus)
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(p)
	return p


func _load_stream(path: String) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	if not ResourceLoader.exists(path):
		push_warning("Audio missing: %s" % path)
		return null
	var loaded := load(path) as AudioStream
	if loaded == null:
		return null
	var stream := loaded.duplicate() as AudioStream
	if stream is AudioStreamOggVorbis:
		var ogg := stream as AudioStreamOggVorbis
		ogg.loop = path.contains("/bgm/") or path.contains("/bgs/")
	_cache[path] = stream
	return stream


func play_bgm(track: String, fade := 0.7) -> void:
	if track == _current_bgm and _music_active.playing:
		return
	var stream := _load_stream(PATH_BGM % track)
	if stream == null:
		return
	_current_bgm = track
	var incoming := _music_b if _music_active == _music_a else _music_a
	var outgoing := _music_active
	incoming.stream = stream
	incoming.volume_db = -40.0
	incoming.play()
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(incoming, "volume_db", 0.0, fade)
	if outgoing.playing:
		tw.tween_property(outgoing, "volume_db", -40.0, fade)
	tw.chain().tween_callback(func():
		if outgoing != incoming:
			outgoing.stop()
			outgoing.volume_db = 0.0
	)
	_music_active = incoming


func stop_bgm(fade := 0.4) -> void:
	_current_bgm = ""
	for p in [_music_a, _music_b]:
		if p.playing:
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -40.0, fade)
			tw.tween_callback(func():
				p.stop()
				p.volume_db = 0.0
			)


func play_bgs(track: String, volume_db := -12.0) -> void:
	var stream := _load_stream(PATH_BGS % track)
	if stream == null:
		return
	_bgs.stream = stream
	_bgs.volume_db = volume_db
	if not _bgs.playing:
		_bgs.play()


func stop_bgs(fade := 0.3) -> void:
	if not _bgs.playing:
		return
	var tw := create_tween()
	tw.tween_property(_bgs, "volume_db", -40.0, fade)
	tw.tween_callback(func():
		_bgs.stop()
		_bgs.volume_db = -12.0
	)


func play_me(track: String, volume_db := 0.0) -> void:
	var stream := _load_stream(PATH_ME % track)
	if stream == null:
		return
	_me.stop()
	_me.stream = stream
	_me.volume_db = volume_db
	_me.play()


func play_sfx(track: String, pitch := 1.0, volume_db := 0.0) -> void:
	_play_pooled(_sfx_pool, PATH_SE % track, pitch, volume_db)


func play_ui(track: String, pitch := 1.0, volume_db := 0.0) -> void:
	_play_pooled(_ui_pool, PATH_SE % track, pitch, volume_db)


func _play_pooled(pool: Array[AudioStreamPlayer], path: String, pitch: float, volume_db: float) -> void:
	var stream := _load_stream(path)
	if stream == null:
		return
	var player: AudioStreamPlayer = null
	for p in pool:
		if not p.playing:
			player = p
			break
	if player == null:
		player = pool[0]
	player.stop()
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.play()


## --- Atalhos semânticos do jogo ---

func sfx_ui_confirm() -> void:
	play_ui("Decision1")


func sfx_ui_cancel() -> void:
	play_ui("Cancel1")


func sfx_ui_cursor() -> void:
	play_ui("Cursor1", 1.0, -4.0)


func sfx_dialogue() -> void:
	play_ui("Book1", randf_range(0.95, 1.05), -2.0)


func sfx_interact() -> void:
	play_ui("Open1")


func sfx_heal() -> void:
	play_sfx("Heal2")


func sfx_item() -> void:
	play_sfx("Item1")


func sfx_attack() -> void:
	play_sfx("Slash1", randf_range(0.95, 1.08))


func sfx_magic() -> void:
	play_sfx("Magic2")


func sfx_damage() -> void:
	play_sfx("Damage2", randf_range(0.92, 1.05))


func sfx_guard() -> void:
	play_sfx("Parry")


func sfx_dodge() -> void:
	play_sfx("Evasion1")


func sfx_counter() -> void:
	play_sfx("Sword1", 1.05)


func sfx_counterspell() -> void:
	play_sfx("Reflection")


func sfx_miss() -> void:
	play_sfx("Miss")


func sfx_battle_start() -> void:
	play_sfx("Battle2")


func sfx_flee() -> void:
	play_sfx("Run")


func sfx_level_up() -> void:
	play_sfx("Powerup")


func sfx_footstep() -> void:
	play_sfx("Move", randf_range(0.9, 1.1), -10.0)


func me_victory() -> void:
	play_me("Victory1")


func me_defeat() -> void:
	play_me("Gameover1")


func me_fanfare() -> void:
	play_me("Fanfare1")


func me_inn() -> void:
	play_me("Inn")


func bgm_menu() -> void:
	stop_bgs()
	play_bgm("Theme1")


func bgm_village() -> void:
	play_bgm("Town2")
	play_bgs("Wind", -18.0)


func bgm_battle(encounter_id: String = "trilha") -> void:
	stop_bgs()
	match encounter_id:
		"mylune":
			play_bgm("Field2")
			play_bgs("Wind", -14.0)
		"cemiterio":
			play_bgm("Battle5")
			play_bgs("Darkness", -16.0)
		_:
			play_bgm("Battle3")
			play_bgs("Darkness", -20.0)


func bgm_victory_stinger() -> void:
	## Mantém BGM baixo enquanto ME toca
	if _music_active:
		_music_active.volume_db = -12.0
