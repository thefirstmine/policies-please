/*
Shader from Godot Shaders - the free shader library.
godotshaders.com/shader/waveforms

This shader is under CC0 license. Feel free to use, improve and
change this shader according to your needs and consider sharing
the modified result to godotshaders.com.
*/

shader_type canvas_item;
render_mode blend_premul_alpha;

uniform int lines = 80; // Amount of lines the waveform is build up of
uniform float amplitude : hint_range(0.0, 1.0) = 0.6; // Height of the wave
uniform float frequency : hint_range(0.0, 0.5) = 0.1; // Set a lower value for a smoother wave
uniform float intensity : hint_range(0.0, 1.0) = 0.35; // Lower values creates gaps in the wave while higher make the wave more solid
uniform float line_sharpness : hint_range(0.0, 1.0) = 0.5; // Fuzzy edges on each line
uniform float line_size : hint_range(0.0, 1.0) = 0.3; // Thickness of the lines
uniform float fade : hint_range(0.0, 0.5) = 0.1; // Blurres the top and bottom of the lines
uniform float rest_size : hint_range(-2., 2.) = -0.2; // The size of the lines when the line is not animating, i.e at value 0. Tweak if Fade is used.
uniform float edge : hint_range(0.0, 0.5) = 0.05; // How close to the edges should the animation beginn
uniform float speed = 0.5; // Speed of wave animation
uniform vec4 color : source_color = vec4(.1, 0.1, 0.5, 1); // Color of wave
uniform bool dot_matrix = false;
uniform int dot_matriz_size = 80;

uniform bool speech_sim = false; // Toggle to simulate speach. Will create a more erratic movement in the wave
uniform float speech_intensity : hint_range(0.0, 2.0) = 0.8; // How fast will the speech movement be
uniform float progress : hint_range(0.0, 1.0) = 1.0; // Use to turn the animation on and off from outside the shader. 0 - off, 1 - on. Can animate values between which will shrink the wave.

float random(vec2 uv) {
	return fract(sin(dot(uv.xy,
	vec2(12.9898,78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);

	// Four corners in 2D of a tile
	float a = random(uv_index);
	float b = random(uv_index + vec2(1.0, 0.0));
	float c = random(uv_index + vec2(0.0, 1.0));
	float d = random(uv_index + vec2(1.0, 1.0));

	vec2 blur = smoothstep(0.0, 1.0, uv_fract);

	return mix(a, b, blur.x) +
				(c - a) * blur.y * (1.0 - blur.x) +
				(d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
	int octaves = 4;
	float amp = 0.5;
	float freq = 4.;
	float value = 0.0;

	for(int i = 0; i < octaves; i++) {
		value += amp * noise(freq * uv - 0.5);
		amp *= 0.6;
		freq *= 2.;
	}
	return value;
}


void fragment()
{
	// Some initialising
	float time = TIME;
	vec4 c = vec4(vec3(0.0), 1.0);
	float f_columns = float(lines);

	// Make some distance to the edges before the animation starts
	float cutoff = smoothstep(0.0, edge, (round ((UV.x) * (f_columns) ) / f_columns) );
	cutoff *= 1. - smoothstep(1.-edge, 1.0, (round ((UV.x) * (f_columns) ) / f_columns) );

	// Speech simulation setup
	float ss = 1.0;
	if (speech_sim == true){
		ss = fbm(vec2(1.0, time * speed * 1.3) * speech_intensity) * 1.5;
	}

	// Create the noise that controlls the animation
	float noise = fbm(vec2( round( (UV.x) * f_columns ) * frequency, time * speed) ) * ss * progress;
	noise *= cutoff; // Apply edge cutoff

	// Make wave values based on the noise
	float wave = smoothstep(1.-intensity, 1.0, noise) * amplitude;
	wave = wave + (rest_size * 0.2);

	// Create the lines
	float line = abs( sin(( f_columns * 3.1416 * UV.x) + 1.5) );
	line = smoothstep(1.-line_size, (1.-line_size) + (1.-line_sharpness), line);

	// Simulate dot_matrix
	if (dot_matrix){
		float dm = abs( sin(( float(dot_matriz_size) * 3.1416 * UV.y) + 1.5) );
		dm = smoothstep(1.-line_size, (1.-line_size) + (1.-line_sharpness), dm);
		line *= dm;
	}

	// Duplicate mask on top an bottom and apply to line
	float mask = 1.0 - smoothstep(wave, wave + fade, abs(UV.y - 0.5) * 2.);
	line *= mask;

	c = vec4(line) * color;

	COLOR = c;
}