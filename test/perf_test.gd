extends Node2D
## SpriteStack2D large-scale performance test.
##
## Spawns a grid of animated SpriteStack2D nodes (carved cars), shows live
## stats on screen and prints a report to the console every few seconds.
##
## "Variants" simulates X different input sources on the same screen: the
## car sheets are duplicated into that many distinct Texture2D resources
## (each with its own RID, like a "local to scene" resource), so nodes
## using different variants cannot share cached frames. Shared frames scale
## with variants x angles, not with node count.
##
## Controls:
##   + / -   add / remove 50 nodes
##   V       cycle input variants (1, 3, 6, 12, 24, 48)
##   M       toggle render mode: pixelated <-> smooth GPU
##   S       toggle shadows
##   R       toggle rotation
##
## Custom start from the command line:
##   godot res://test/perf_test.tscn -- count=400 variants=12

const SHEET_PATHS: Array[String] = [
	"uid://bw86m4ggx7v4j",
	"uid://b76qv3h4pt6nr",
]
const VARIANT_STEPS: Array[int] = [1, 3, 6, 12, 24, 48]
const BATCH_ADD := 50
const SPACING := Vector2(50, 40)

@export var initial_count := 150
## Distinct input textures to simulate (cycled from the car sheets).
@export var initial_variants := 3
## Nodes spawned per frame while ramping up (each first draw carves+renders).
@export var batch_per_frame := 8
@export var report_interval := 5.0
## View directions for the pixelated mode. Fewer directions mean fewer
## cached frames per variant at large scale (90 = 4 deg steps).
@export var node_directions := 90

enum Mode { PIXELATED, SMOOTH_GPU }

var _mode: Mode = Mode.PIXELATED
var _shadows := true
var _rotate := true

var _sheets: Array[Texture2D] = []
var _variants: Array[Texture2D] = []
var _target := 0
var _stacks: Array[SpriteStack2D] = []
var _hud: Label
var _deltas: Array[float] = []
var _report_t := 0.0
var _hud_t := 0.0
var _spawn_ms := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 12345
	for path in SHEET_PATHS:
		_sheets.append(load(path))
	RenderingServer.set_default_clear_color(Color(0.13, 0.13, 0.15))
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("count="):
			initial_count = maxi(0, arg.trim_prefix("count=").to_int())
		elif arg.begins_with("variants="):
			initial_variants = maxi(1, arg.trim_prefix("variants=").to_int())
	_target = initial_count
	_build_variants(initial_variants)
	_build_hud()
	print("[PerfTest] target %d nodes | %s | controls: +/- nodes, V variants, M mode, S shadows, R rotation" % [
		_target, _config_name()])


## Build X distinct input textures by duplicating the car sheets. Each
## duplicate is its own resource (own RID) — the runtime equivalent of a
## "local to scene" texture — so frames are cached per variant.
func _build_variants(count: int) -> void:
	_variants.clear()
	for i in count:
		var src := _sheets[i % _sheets.size()]
		if i < _sheets.size():
			_variants.append(src) # first pass: the original resources
		else:
			_variants.append(ImageTexture.create_from_image(src.get_image()))
	for j in _stacks.size():
		_stacks[j].texture = _variants[j % _variants.size()]


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_hud = Label.new()
	_hud.position = Vector2(8, 6)
	_hud.add_theme_font_size_override("font_size", 14)
	_hud.add_theme_color_override("font_color", Color.WHITE)
	_hud.add_theme_color_override("font_outline_color", Color.BLACK)
	_hud.add_theme_constant_override("outline_size", 4)
	layer.add_child(_hud)


func _config_name() -> String:
	var mode_name: String
	match _mode:
		Mode.PIXELATED:
			mode_name = "pixelated (%d directions)" % node_directions
		Mode.SMOOTH_GPU:
			mode_name = "smooth GPU"
	return "%d input variants | %s | shadows %s | rotation %s" % [
		_variants.size(),
		mode_name,
		"ON" if _shadows else "OFF",
		"ON" if _rotate else "OFF"]


func _apply_config(node: SpriteStack2D) -> void:
	node.pixelated = _mode == Mode.PIXELATED
	node.enable_shadow = _shadows
	node.shadow_color = Color(0, 0, 0, 0.4)
	node.shadow_offset = Vector2(-3, -8)
	node.auto_rotate = _rotate


func _spawn_one() -> void:
	var i := _stacks.size()
	var view := get_viewport_rect().size
	var cols := maxi(1, int(view.x / SPACING.x) - 1)
	var rows_fit := maxi(1, int((view.y - 40.0) / SPACING.y))
	var row := i / cols
	var node := SpriteStack2D.new()
	node.texture = _variants[i % _variants.size()]
	node.source_mode = SpriteStack2D.SourceMode.FACES_4
	node.x_rotations = 45.0
	node.directions = node_directions
	node.y_rotations = _rng.randf_range(0.0, 360.0)
	node.rotate_speed = _rng.randf_range(20.0, 120.0)
	node.position = Vector2(
		SPACING.x * (0.75 + (i % cols)) + (row / rows_fit) * 9.0,
		SPACING.y * (1.0 + (row % rows_fit)) + 34.0)
	_apply_config(node)
	add_child(node)
	_stacks.append(node)


func _reapply_all() -> void:
	for node in _stacks:
		_apply_config(node)
	_deltas.clear()
	_report_t = 0.0
	print("[PerfTest] config changed -> %s" % _config_name())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_EQUAL, KEY_PLUS, KEY_KP_ADD:
				_target += BATCH_ADD
			KEY_MINUS, KEY_KP_SUBTRACT:
				_target = maxi(0, _target - BATCH_ADD)
			KEY_V:
				var idx := VARIANT_STEPS.find(_variants.size())
				_build_variants(VARIANT_STEPS[(idx + 1) % VARIANT_STEPS.size()])
				_reapply_all()
			KEY_M:
				_mode = ((_mode + 1) % 2) as Mode
				_reapply_all()
			KEY_S:
				_shadows = not _shadows
				_reapply_all()
			KEY_R:
				_rotate = not _rotate
				_reapply_all()


func _process(delta: float) -> void:
	# Ramp the node count toward the target in batches.
	if _stacks.size() < _target:
		var t0 := Time.get_ticks_usec()
		for i in mini(batch_per_frame, _target - _stacks.size()):
			_spawn_one()
		_spawn_ms += (Time.get_ticks_usec() - t0) / 1000.0
		if _stacks.size() == _target:
			print("[PerfTest] spawned %d nodes, spawn cost total %.0f ms (%.2f ms/node)" % [
				_stacks.size(), _spawn_ms, _spawn_ms / maxf(1.0, _stacks.size())])
	elif _stacks.size() > _target:
		while _stacks.size() > _target:
			_stacks.pop_back().queue_free()

	_deltas.append(delta)
	if _deltas.size() > 4000:
		_deltas = _deltas.slice(_deltas.size() - 2000)

	_hud_t += delta
	if _hud_t >= 0.25:
		_hud_t = 0.0
		_update_hud()

	_report_t += delta
	if _report_t >= report_interval and _stacks.size() == _target:
		_report_t = 0.0
		_report()


func _stats() -> Dictionary:
	if _deltas.is_empty():
		return {}
	var ds := _deltas.duplicate()
	ds.sort()
	var sum := 0.0
	for d in ds:
		sum += d
	var avg: float = sum / ds.size()
	return {
		fps_avg = 1.0 / avg,
		ms_avg = avg * 1000.0,
		ms_p95 = ds[mini(ds.size() - 1, int(ds.size() * 0.95))] * 1000.0,
		ms_max = ds[ds.size() - 1] * 1000.0,
	}


func _report() -> void:
	var s := _stats()
	if s.is_empty():
		return
	print("[PerfTest] nodes=%d | fps avg %.1f | frame ms avg %.2f / p95 %.2f / max %.2f | draw calls %d | shared frames %d | shared sources %d | static mem %.1f MB | %s" % [
		_stacks.size(), s.fps_avg, s.ms_avg, s.ms_p95, s.ms_max,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		SpriteStack2D.get_shared_frame_cache_size(),
		SpriteStack2D.get_shared_source_cache_size(),
		Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		_config_name()])
	_deltas.clear()


func _update_hud() -> void:
	var s := _stats()
	var spawning := ""
	if _stacks.size() < _target:
		spawning = "  (spawning... %d/%d)" % [_stacks.size(), _target]
	var line2 := "warming up..."
	if not s.is_empty():
		line2 = "FPS %.0f | frame %.2f ms (p95 %.2f, max %.2f)" % [
			s.fps_avg, s.ms_avg, s.ms_p95, s.ms_max]
	_hud.text = "SpriteStack2D Perf Test — %d nodes%s\n%s\n%s\nDraw calls %d | Shared frames %d | Sources %d | Static mem %.1f MB\n[+/-] ±%d nodes   [V] variants   [M] mode   [S] shadows   [R] rotation" % [
		_stacks.size(), spawning,
		line2,
		_config_name(),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		SpriteStack2D.get_shared_frame_cache_size(),
		SpriteStack2D.get_shared_source_cache_size(),
		Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		BATCH_ADD]
