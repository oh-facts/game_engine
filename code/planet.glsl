#version 450
#extension GL_ARB_bindless_texture : enable
uniform vec2 u_screen_size;
uniform vec3 u_cam_pos;
uniform mat4 u_proj;
uniform mat4 u_view;

@common_shader_end;

void main()
{
	vec2 vertices[] = 
	{
		{-1, -3},
		{ 3,  1},
		{-1,  1},
	};
	
	vec2 vertex = vertices[gl_VertexID];
	gl_Position = vec4(vertex, 0, 1);
}

@vertex_shader_end;

layout (location=0) out vec4 out_color;

const int maxstps = 256;
const float maxdst = 10000.0;
const float mindst = 0.001;
const float pi = 3.1415927410125732421875;
const float tau = 6.283185482025146484375;
const float planet_radius = 1000;

float circle_sdf(vec2 p, float r)
{
	return length(p) - r;
}

float sphere_sdf(vec3 p, float r)
{
	return length(p) - r;
}

// Precision-adjusted variations of https://www.shadertoy.com/view/4djSRW
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	float u = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), u);
}

float noise(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);
	
	// Four corners in 2D of a tile
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	
	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));
	
	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}


float noise(vec3 x) {
	const vec3 step = vec3(110, 241, 171);
	
	vec3 i = floor(x);
	vec3 f = fract(x);
	
	// For performance, compute the base input to a 1D hash from the integer part of the argument and the 
	// incremental change to the 1D based on the 3D -> 1D wrapping
	float n = dot(i, step);
	
	vec3 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
								 mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
						 mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
								 mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}

float get_elevation(vec3 p)
{
	float el = 10;
	
	el += noise(p * 0.005) * 60.0;
	el += noise(p * 0.02 + p * 0.01) * 10.0;
	
	if (el > 60)
	{
		el = 100;
	}
	
	// water
	el = max(40, el);
	
	return el;
}

float map(vec3 p)
{
	float el = get_elevation(p);
	return sphere_sdf(p, planet_radius + el) * 0.8;
}

vec3 get_normal(vec3 p) 
{
	vec3 pe = p - 0.01;
	vec3 n = map(p) - vec3(map(vec3(pe.x, p.yz)), map(vec3(p.x, pe.y, p.z)), map(vec3(p.xy, pe.z)));
	return normalize(n);
}

void main()
{
	vec2 uv  = (gl_FragCoord.xy / u_screen_size) * 2.0 - 1.0;
	
	mat4 cam_to_world = inverse(u_view);
	mat4 clip_to_cam = inverse(u_proj);
	
	vec4 ray_origin = cam_to_world * vec4(0.0, 0.0, 0.0, 1.0);
	
	vec3 ro = ray_origin.xyz;
	
	vec4 clip_pos = vec4(uv, -1.0, 1.0);
	vec4 view_pos = clip_to_cam * clip_pos;
	view_pos /= view_pos.w;
	
	vec4 ray_target = cam_to_world * vec4(view_pos.xyz, 0.0);
	
	vec3 rd = normalize(ray_target.xyz);
	
	float total_dst = 0;
	for (int i = 0; i < maxstps; i++)
	{
		vec3 p = ro + rd * total_dst;
		
		float d = map(p);
		
		if ((d < mindst) || (d > maxdst))
		{
			//out_color = vec4(1, 1, 0, 1);
			//out_color = vec4(uv.x, uv.y, 0, 1);
			vec3 light = normalize(vec3(1,1,1));
			vec3 n = get_normal(p);
			//out_color = vec4(n, 1.0);
			float diff = dot(n, light);
			vec3 dif = vec3(diff);
			float el = get_elevation(p);
			vec4 color = vec4(0,1,0,1);
			
			if (el <= 40)
			{
				color = vec4(0,0,1,1);
			}
			else if (el > 60)
			{
				color = vec4(1,1,1,1);
			}
			
			out_color = color * vec4(dif, 1.0);
			
			break;
		}
		
		total_dst += d;
	}
}