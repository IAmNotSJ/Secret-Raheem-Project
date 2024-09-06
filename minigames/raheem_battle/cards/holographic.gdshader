// HSV to RBG from https://www.rapidtables.com/convert/color/hsv-to-rgb.html
// Rotation matrix from https://en.wikipedia.org/wiki/Rotation_matrix

shader_type canvas_item;

uniform bool active = true;
uniform bool darkened = false;
uniform vec4 tint_color : source_color;
uniform float direction: hint_range(0, 1) = 0.5;
uniform float effect_alpha_mult : hint_range(0,1) = 1.0;
uniform float position: hint_range(0, 0.5) = 0.25;

uniform sampler2D gradient;
uniform sampler2D noise;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 final = color;
	
	final = final * tint_color;
	if (active) {
		vec4 gradient_tex = texture(gradient, vec2((position+(NORMAL.y*direction*2.0-NORMAL.x*(1.0-direction)*2.0)/2.0+(UV.y*direction+UV.x*(1.0-direction))/2.0), 0.0));
		vec4 noise_tex = texture(noise, UV);
		
		if (color.a > 0.3) {
			final = mix(color, vec4(mix(gradient_tex.rgb, noise_tex.rgb*2.0, 0.1), 1.0), effect_alpha_mult*gradient_tex.a*effect_alpha_mult);
		}
	}
	if (darkened) {
		final *= 0.8;
	}
	
	COLOR = final;
}