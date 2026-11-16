extends Control

@export var starfield: ColorRect            # node with your starfield script (needs its `scroll` var)
@export var planet_shader: Shader           # planet.gdshader
@export_range(1, 10) var min_planets := 7
@export_range(1, 10) var max_planets := 20
@export var min_diameter := 48.0            # px on screen
@export var max_diameter := 160.0
@export var few_planets_scale := 2.0     # size multiplier when the level has the minimum number of planets
@export var many_planets_scale := 0.6    # size multiplier when the level has the maximum number
@export var parallax := 1.0                 # planet speed relative to `scroll` (shared by all planets)
@export var pixel_size := 2.0               # screen px per "planet pixel" (1 if your game uses a low-res viewport)
@export var light_angle := 35.0
@export var level_seed := 0                 # 0 = random each level, otherwise deterministic
@export var world_origin := Vector2.ZERO    # top-left of the area where planets are placed

const PLANET_RADIUS := 0.8                  # must match the shader's planet_radius

const PALETTE_PARAMS := {
	# rocky
	"ocean_shallow": Color("29ADFF"), "ocean_deep": Color("1D2B53"),
	"land_low": Color("AB5236"), "land_high": Color("C2C3C7"),
	"desert_color": Color("FFCCAA"), "vegetation_color": Color("008751"),
	"ice_color": Color("FFF1E8"), "lava_color": Color("FFA300"),
	# gas
	"gas_color_a": Color("FFCCAA"), "gas_color_b": Color("AB5236"), "gas_color_c": Color("FFF1E8"),
	"gas_spot_color": Color("FF004D"),
	"greenhouse_light": Color("FFEC27"), "greenhouse_dark": Color("FFA300"),
	# effects
	"atmosphere_color": Color("29ADFF"), "twilight_color": Color("FFA300"),
	"cloud_color": Color("FFF1E8"), "city_color": Color("FFEC27"), "city_day_color": Color("C2C3C7"),
	"fire_color": Color("FFA300"), "lightning_color": Color("FFF1E8"), "life_dot_color": Color("5F574F"),
	# light
	"sun_color": Color("FFF1E8"),
	"hue_variation": 0.0,        # hue rotation would push colors off-palette before snapping
	"ambient_light": 0.08,
}

var _planets: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	generate()

# Call this once when the level starts (it is also called from _ready)
func generate() -> void:
	for p in _planets:
		p.node.queue_free()
	_planets.clear()

	if level_seed != 0:
		_rng.seed = level_seed
	else:
		_rng.randomize()

	var world := Vector2(Game.WORLD_WIDTH, Game.WORLD_HEIGHT)   # spelled as in your constants
	var count := _rng.randi_range(mini(min_planets, max_planets), max_planets)

	for i in count:
		var t := _rng.randf()
		var d := lerpf(min_diameter, max_diameter, t * t)       # more small planets than big ones

		# Size the quad in whole "planet pixels" so every cell is exactly pixel_size screen px
		var cells := maxi(roundi(d / PLANET_RADIUS / pixel_size), 4)
		var quad := float(cells) * pixel_size
		var diameter := quad * PLANET_RADIUS

		var rect := ColorRect.new()
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.size = Vector2.ONE * quad

		var mat := ShaderMaterial.new()
		mat.shader = planet_shader
		mat.set_shader_parameter("planet_type", 8)              # random type from seed
		mat.set_shader_parameter("randomize_params", true)
		mat.set_shader_parameter("planet_seed", float(_rng.randi_range(0, 2000)))
		mat.set_shader_parameter("planet_radius", PLANET_RADIUS)
		mat.set_shader_parameter("light_angle_deg", light_angle)
		mat.set_shader_parameter("pixelate_mode", 2)            # Fixed
		mat.set_shader_parameter("fixed_pixels", float(cells) * PLANET_RADIUS)  # px across the disc
		for key in PALETTE_PARAMS:
			mat.set_shader_parameter(key, PALETTE_PARAMS[key])
		mat.set_shader_parameter("use_palette", true)
		rect.material = mat
		add_child(rect)

		_planets.append({
			"node": rect,
			"pos": _find_position(world, diameter),
			"diameter": diameter,
		})

func _find_position(world: Vector2, diameter: float) -> Vector2:
	var pos := Vector2.ZERO
	for attempt in 30:                                          # avoid overlapping planets
		pos = world_origin + Vector2(_rng.randf(), _rng.randf()) * world
		var ok := true
		for p in _planets:
			if pos.distance_to(p.pos) < (diameter + p.diameter) * 0.65:
				ok = false
				break
		if ok:
			break
	return pos

func _process(_delta: float) -> void:
	var origin: Vector2 = starfield.scroll if starfield else Vector2.ZERO
	var view_rect := Rect2(Vector2.ZERO, get_viewport_rect().size)
	var grid := Vector2.ONE * pixel_size

	for p in _planets:
		var rect: ColorRect = p.node
		var center: Vector2 = p.pos - origin * parallax
		var top_left := (center - rect.size * 0.5).snapped(grid)   # keep cells aligned to the pixel grid
		rect.visible = view_rect.intersects(Rect2(top_left, rect.size))  # skip the heavy shader when off-screen
		rect.position = top_left
