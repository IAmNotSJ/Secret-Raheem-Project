// HSV to RBG from https://www.rapidtables.com/convert/color/hsv-to-rgb.html
// Rotation matrix from https://en.wikipedia.org/wiki/Rotation_matrix

shader_type canvas_item;

uniform bool active = true;
uniform bool darkened = false;
uniform vec4 tint_color : source_color;
uniform float direction: hint_range(0, 1) = 0.5;
uniform float minimum : hint_range(0, 1) = 0.0;
uniform float effect_alpha_mult : hint_range(0,1) = 1.0;

uniform sampler2D gradient;
uniform sampler2D noise;

vec4 overlay(vec4 bottom, vec4 top){
	vec4 result;
	for (int i=0; i < 3; i++) {
		if (bottom[i] > 0.5) {
			float v = (1.0 - bottom[i]) / 0.5;
			float m = bottom[i] - (1.0 - bottom[i]);
			result[i] = (top[i] * top[3] * v) + m;
		}
		else {
			float v = bottom[i] / 0.5;
			result[i] = top[i] * v;
		}
	}
	result = vec4(result.rgb, bottom.a);
	return result;
}



void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 final = color;
	
	float position = float(1) / float(3) * cos(TIME / 1.2) + 0.25;
	
	final = final * tint_color;
	
	if (active) {
		vec4 gradient_tex = texture(gradient, vec2((position+(NORMAL.y*direction*2.0-NORMAL.x*(1.0-direction)*2.0)/2.0+(UV.y*direction+UV.x*(1.0-direction))/2.0), 0.0));
		
		vec4 noise_tex = texture(noise, UV);
		vec4 mixed = vec4(mix(gradient_tex.rgb, noise_tex.rgb*2.0, 0.1), 1); 
		//mixed *= effect_alpha_mult;
		
		
		for (int i = 0; i < 3; i++) {
			if (final[i] > minimum) {
				final = overlay(final, mixed);
			}
			else {
				final[i] = final[i] + (mixed[i]);
			}
		}
	}
	if (darkened) {
		final *= 0.8;
	}
	
	COLOR = final;
}