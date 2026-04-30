extends Node2D

var radius := 20.0
var circle_color := Color.WHITE
var thickness := 4.0

func setup(new_color: Color, new_radius: float):
	circle_color = new_color
	radius = new_radius

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(8, 8), 0.8)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()

func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, 96, circle_color, thickness, true)
	draw_arc(Vector2.ZERO, radius * 0.55, 0, TAU, 96, circle_color.lightened(0.3), thickness * 0.6, true)
