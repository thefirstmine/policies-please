//---CRT Shader---
shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1800) = 50.0;
uniform float scanline_speed : hint_range(-10.0, 10.0) = .01;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

vec2 uv_curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;

	//// You can modify the numbers and try different values
	//uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 3);
	//uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 3);

	uv = (uv / 2.0) + 0.5;
	return uv;
}

void fragment()
{
	vec2 curved_uv = uv_curve(SCREEN_UV);

	float r = texture(SCREEN_TEXTURE, curved_uv + vec2(SCREEN_PIXEL_SIZE.x * 0.0), 0.2).r;
	float g = texture(SCREEN_TEXTURE, curved_uv + vec2(SCREEN_PIXEL_SIZE.x * 1.3), 0.2).g;
	float b = texture(SCREEN_TEXTURE, curved_uv + vec2(SCREEN_PIXEL_SIZE.x * -1.3), 0.2).b;

	// Add time-based offset for moving scanlines
	float s = sin((curved_uv.y + TIME * scanline_speed) * scanline_count * PI * 15.0);
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec4 scan_line = vec4(vec3(pow(s, 0.25)), 1.0);

	COLOR = vec4(r, g, b, 1.0) * scan_line;
}