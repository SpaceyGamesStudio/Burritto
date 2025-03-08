shader_type canvas_item;

uniform sampler2D noise_texture : hint_default_black, repeat_enable;
uniform float speed : hint_range(0.0, 5.0) = 0.1;
uniform sampler2D tone_mapping;

void vertex() {
	
}

void fragment() {
	float tex_alpha = textureLod(TEXTURE, UV, 3.0).a;
	vec2 uv = vec2(UV.x + -TIME * speed, UV.y);
	float pattern_intensity = texture(noise_texture, uv).r;
	float intensity = tex_alpha * pattern_intensity;
	
	COLOR = texture(tone_mapping, vec2(intensity));
}
