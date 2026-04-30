extends Node2D

var blob_color := Color.WHITE
var points_count := 96
var base_radius := 40.0
var wobble := 20.0
var life := 1.2
var seed := 0.0

func setup(new_color: Color, new_radius: float):
	blob_color = new_color
	base_radius = new_radius
	seed = randf() * 1000.0

func _ready():
	scale = Vector2(0.2, 0.2)

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(randf_range(3.0, 7.0), randf_range(3.0, 7.0)), life)
	tween.parallel().tween_property(self, "rotation", randf_range(-4.0, 4.0), life)
	tween.parallel().tween_property(self, "modulate:a", 0.0, life)

	await tween.finished
	queue_free()

func _process(delta):
	queue_redraw()

func _draw():
	var t = Time.get_ticks_msec() / 1000.0
	var pts = PackedVector2Array()

	for i in range(points_count):
		var a = TAU * float(i) / float(points_count)

		var wave1 = sin(a * 3.0 + t * 3.0 + seed)
		var wave2 = sin(a * 7.0 - t * 2.0 + seed)
		var wave3 = cos(a * 5.0 + t * 1.5)

		var r = base_radius + (wave1 + wave2 + wave3) * wobble

		pts.append(Vector2(cos(a), sin(a)) * r)

	draw_colored_polygon(pts, blob_color)
	draw_polyline(pts, Color(blob_color.r, blob_color.g, blob_color.b, 0.9), 3.0, true)
