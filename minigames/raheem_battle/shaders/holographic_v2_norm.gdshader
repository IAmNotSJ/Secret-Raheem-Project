shader_type spatial;
render_mode blend_mix;

uniform vec3 hue_color:source_color;

uniform float color_density;
uniform vec3 shift;



void fragment() {

vec3 color_func;
{
	vec3 c = shift;
	float max1 = max(c.r, c.g);
	float max2 = max(max1, c.b);
	color_func = vec3(max2, max2, max2);
}


float multiplied_1 = color_density *  color_func.r;
float hue_shift = multiplied_1 * color_func.g;

vec3 color_hsv;
{
	vec3 c = hue_color;
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	color_hsv=vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

color_hsv.x = mod((color_hsv.x + hue_shift), 1.0f);

vec3 color_rgb;
{
	vec3 c = color_hsv;
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	color_rgb=c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


ALBEDO = vec3(0.0, 1.0, 0.0);


}