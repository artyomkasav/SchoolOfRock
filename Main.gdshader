shader_type canvas_item;

uniform float time_scale = 1.0;
uniform float intensity = 0.08;

float noise(vec2 p) {
	return sin(p.x) * sin(p.y);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * time_scale;

	vec2 p = uv * 6.0;

	float n1 = noise(p + vec2(t, t * 0.7));
	float n2 = noise(p * 1.7 + vec2(-t * 0.8, t));

	uv.x += sin(uv.y * 18.0 + t * 2.0 + n1 * 3.0) * intensity;
	uv.y += cos(uv.x * 18.0 + t * 2.0 + n2 * 3.0) * intensity;

	float r = 0.5 + 0.5 * sin(t + uv.x * 8.0 + n1 * 4.0);
	float g = 0.5 + 0.5 * sin(t * 1.2 + uv.y * 8.0 + n2 * 4.0);
	float b = 0.5 + 0.5 * sin(t * 1.5 + (uv.x + uv.y) * 6.0);

	COLOR = vec4(r, g, b, 0.35);
}