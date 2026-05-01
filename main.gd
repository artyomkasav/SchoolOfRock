extends Node2D

@onready var player = $Player

var circle_scene = preload("res://Circle.tscn")
var blob_scene = preload("res://Blob.tscn")
var is_playing = false
var particles = []
var particle_count = 400
var audio_players = []
var max_players = 12
var volume_value = 0.8
var pitch_value = 1.0
var speed_value = 1.0
var fractals = []
var fractal_count = 20
var pulse_strength = 0.0
var fractal_move_speed_value = 1.0
var fractal_spin_speed_value = 1.0

var particle_speed_value = 1.0
var particle_count_value = 80

var blob_count_value = 5
var sounds = [
	preload("res://sounds/s1.mp3"),
	preload("res://sounds/s2.mp3"),
	preload("res://sounds/s3.mp3"),
	preload("res://sounds/s4.mp3"),
	preload("res://sounds/s5.mp3"),
	preload("res://sounds/s6.wav"),
	preload("res://sounds/s7.wav"),
	preload("res://sounds/s8.wav"),
	preload("res://sounds/s9.wav"),
]
func _ready() -> void:
	randomize()

	var ui = $CanvasLayer/Panel/VBoxContainer

	ui.get_node("VolumeSlider").value_changed.connect(_on_volume_changed)
	ui.get_node("PitchSlider").value_changed.connect(_on_pitch_changed)
	ui.get_node("RandomSpeedSlider").value_changed.connect(_on_speed_changed)
	ui.get_node("FractalCountSlider").value_changed.connect(_on_fractal_slider_changed)
	ui.get_node("FractalMoveSpeedSlider").value_changed.connect(_on_fractal_move_speed_changed)
	ui.get_node("FractalSpinSpeedSlider").value_changed.connect(_on_fractal_spin_speed_changed)
	ui.get_node("ParticleCountSlider").value_changed.connect(_on_particle_count_changed)
	ui.get_node("ParticleSpeedSlider").value_changed.connect(_on_particle_speed_changed)
	ui.get_node("BlobCountSlider").value_changed.connect(_on_blob_count_changed)
	$CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for i in range(max_players):
		var new_player = AudioStreamPlayer.new()
		add_child(new_player)
		audio_players.append(new_player)

	create_particles()
	create_fractals()
func play_sound(index):
	var free_player = null

	for p in audio_players:
		if not p.playing:
			free_player = p
			break

	if free_player == null:
		free_player = audio_players[0]

	free_player.stream = sounds[index]
	free_player.pitch_scale = pitch_value
	free_player.volume_db = linear_to_db(volume_value)
	free_player.play()
	pulse_strength = 1.0
	spawn_visual(index)
	
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				play_sound(0)
			KEY_2:
				play_sound(1)
			KEY_3:
				play_sound(2)
			KEY_4:
				play_sound(3)
			KEY_5:
				play_sound(4)
			KEY_6:
				play_sound(5)
			KEY_7:
				play_sound(6)
			KEY_8:
				play_sound(7)
			KEY_9:
				play_sound(8)

func spawn_visual(index := 0):
	for i in range(blob_count_value):
		var b = blob_scene.instantiate()

		b.position = Vector2(
			randf() * get_viewport_rect().size.x,
			randf() * get_viewport_rect().size.y
		)

		var hue = fmod((float(index) / sounds.size()) + randf_range(-0.25, 0.25), 1.0)
		var color = Color.from_hsv(hue, 1.0, 1.0, 0.22)

		add_child(b)
		b.setup(color, randf_range(18, 45) * pitch_value)

		await get_tree().create_timer(0.035 / speed_value).timeout

func _draw():
	var time = Time.get_ticks_msec() / 1000.0
	
	for p in particles:
		var col = Color.from_hsv(p["hue"], 0.9, 1.0, 0.65)
		draw_circle(p["pos"], p["radius"], col)
		
		for q in particles:
			if p == q:
				continue
			
			var dist = p["pos"].distance_to(q["pos"])
			
			if dist < 120:
				var alpha = 1.0 - dist / 120.0
				var line_col = col
				line_col.a = alpha * 0.25
				draw_line(p["pos"], q["pos"], line_col, 1.0)	
	var center = get_viewport_rect().size / 2
	
	for i in range(8):
		var angle = time * (0.4 + i * 0.1) + i
		var r = 100 + sin(time + i) * 50
		var pos = center + Vector2(cos(angle), sin(angle)) * r
		var col = Color.from_hsv(fmod(time * 0.05 + i * 0.1, 1.0), 1.0, 1.0, 0.25)
		draw_arc(pos, 40 + sin(time * 2.0 + i) * 20, 0, TAU, 96, col, 2.0, true)
	draw_fractal_spiral()
	
func draw_fractal_spiral():
	var screen = get_viewport_rect().size
	var t = Time.get_ticks_msec() / 1000.0
	
	for f in fractals:
		var center = Vector2(
			screen.x * 0.5 + sin(t * f["move_speed"] * fractal_move_speed_value + f["phase"]) * screen.x * 0.35,
			screen.y * 0.5 + cos(t * f["move_speed"] * fractal_move_speed_value * 1.3 + f["phase"]) * screen.y * 0.35
		)
		
		var points = PackedVector2Array()
		
		for i in range(f["points"]):
			var n = float(i)
			
			var angle = n * 0.12 + t * f["spin_speed"] * fractal_spin_speed_value + sin(n * 0.6 + t) * 10.0
			
			var radius = sqrt(n) * f["size"]
			radius += sin(t * 2.0 + n * 0.03 + f["phase"]) * 40.0
			radius += cos(t * 1.3 + n * 0.015) * 25.0
			radius += pulse_strength * 120.0
			
			var pos = center + Vector2(cos(angle), sin(angle)) * radius
			points.append(pos)
		
		for i in range(points.size() - 1):
			var hue = fmod(float(i) / points.size() + t * 0.12 + f["phase"], 1.0)
			var alpha = 0.25 + pulse_strength * 0.5
			var col = Color.from_hsv(hue, 1.0, 1.0, alpha)
			
			draw_line(points[i], points[i + 1], col, 1.5 + pulse_strength * 4.0)
func create_fractals():
	var screen = get_viewport_rect().size
	
	for i in range(fractal_count):
		fractals.append({
			"center": Vector2(randf() * screen.x, randf() * screen.y),
			"move_speed": randf_range(1.0, 3.2),
			"spin_speed": randf_range(0.4, 2.5),
			"size": randf_range(4.0, 11.0),
			"phase": randf() * 100.0,
			"points": randi_range(500, 1300)
		})

func create_particles():
	var screen = get_viewport_rect().size
	
	for i in range(particle_count):
		particles.append({
			"pos": Vector2(randf() * screen.x, randf() * screen.y),
			"vel": Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5)),
			"radius": randf_range(2, 8),
			"hue": randf()
		})

func _on_volume_changed(value):
	volume_value = value

func _on_pitch_changed(value):
	pitch_value = value

func _on_speed_changed(value):
	speed_value = value

func _on_random_button_pressed():
	is_playing = !is_playing
	
	if is_playing:
		$CanvasLayer/Panel/VBoxContainer/RandomButton.text = "STOP RANDOM"
		play_random_sequence()
	else:
		$CanvasLayer/Panel/VBoxContainer/RandomButton.text = "START RANDOM"

func _on_fractal_move_speed_changed(value):
	fractal_move_speed_value = value

func _on_fractal_spin_speed_changed(value):
	fractal_spin_speed_value = value

func _on_particle_speed_changed(value):
	particle_speed_value = value

func _on_blob_count_changed(value):
	blob_count_value = int(value)

func _on_particle_count_changed(value):
	particle_count_value = int(value)
	particle_count = particle_count_value
	particles.clear()
	create_particles()

func _on_fractal_slider_changed(value):
	fractal_count = int(value)
	fractals.clear()
	create_fractals()
	
	if has_node("CanvasLayer/FractalLabel"):
		$CanvasLayer/Panel/VBoxContainer/FractalLabel.text = "Fractals: " + str(fractal_count)

func play_random_sequence():
	while is_playing:
		var index = randi() % sounds.size()
		play_sound(index)
		
		var wait_time = randf_range(0.01, 0.2) / speed_value
		await get_tree().create_timer(wait_time).timeout

func _process(delta):
	var screen = get_viewport_rect().size
	pulse_strength = lerp(pulse_strength, 0.0, delta * 3.0)
	for p in particles:
		p["pos"] += p["vel"] * speed_value * particle_speed_value
		
		if p["pos"].x < 0 or p["pos"].x > screen.x:
			p["vel"].x *= -1
		
		if p["pos"].y < 0 or p["pos"].y > screen.y:
			p["vel"].y *= -1
		
		p["hue"] = fmod(p["hue"] + delta * 0.05 * speed_value, 1.0)
	
	queue_redraw()
