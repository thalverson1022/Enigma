shader_type canvas_item;
render_mode blend_mix;

uniform float alpha_threshold : hint_range(0.0, 1.0, 0.01) = 0.04;

void fragment() {
	float mask = step(alpha_threshold, texture(TEXTURE, UV).a);
	COLOR = vec4(COLOR.rgb, COLOR.a * mask);
}
