shader_type canvas_item;

uniform float intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_rgb : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float vignette_noise : hint_range(0.0, 1.0) = 0.15;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


float vignette(vec2 uv) {
	// Center coordinates
	vec2 centered = uv - vec2(0.5);
	
	// Distance from center
	float dist = length(centered);
	
	// Angle around the circle
	float angle = atan(centered.y, centered.x);
	
	// Wavy/spiky noise around the circumference
	//float noise = 
		//sin(angle * 8.0) * 0.5 +
		//sin(angle * 17.0) * 0.3 +
		//sin(angle * 31.0) * 0.2;
	float noise = 
		sin(angle * 8.0 + TIME * 3.0) * 0.3 +
		sin(angle * 17.0 - TIME * 4.0) * 0.3 +
		sin(angle * 31.0 + TIME * 8.0) * 0.1;
	
	// Distort the circular radius
	dist += noise * vignette_noise * 0.08;
	
	// Convert back into a vignette value
	float v = 1.0 - smoothstep(0.25, 0.75, dist);
	
	// pulsing
	float pulse = 1.0 + sin(TIME * 16.0) * 0.4;
	
	return pow(v, (pulse * intensity) * vignette_opacity);
}


void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 text = texture(TEXTURE, UV);
	
	text.rgba *= vignette_rgb.rgba;
	text.rgba *= (1.0 - vignette(UV));
	
	COLOR = vec4((text.rgb) * color.rgb, text.a);
}
