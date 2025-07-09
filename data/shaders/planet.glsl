#version 450
#extension GL_ARB_bindless_texture : enable
uniform mat4 u_view;
uniform mat4 u_proj;
uniform vec2 u_screen_size;
uniform uvec2 u_height_map;

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

float circle_sdf(vec2 p, float r)
{
	return length(p) - r;
}

float sphere_sdf(vec3 p, float r)
{
	return length(p) - r;
}

struct Raymarch_Result
{
	float dist;
	vec4 color;
};

struct Intersection_Result
{
	float t1;
	float t2;
	bool hit;
};

#define eps 1.0

#define planet_radius 1000.0
#define sea_level (planet_radius - 10)
#define num_steps (256)

// I also want to make saturn rings

Intersection_Result ray_sphere_intersection(vec3 ro, vec3 rd, float r)
{
	Intersection_Result res;
	res.hit = false;
	
	float a = dot(rd, rd);
	float b = 2.0 * dot(ro, rd);
	float c = dot(ro, ro) - r * r;
	
	float discriminant = b * b - 4.0 * a * c;
	
	if (discriminant < 0.0)
		return res;
	
	float sqrt_discriminant = sqrt(discriminant);
	
	float t1 = (-b - sqrt_discriminant) / (2.0 * a);
	float t2 = (-b + sqrt_discriminant) / (2.0 * a);
	
	res.hit = true;
	if (t2 >= 0.0)
	{
		res.t1 = t1;
		res.t2 = t2;
	}
	
	return res;
}

#define PI 3.14159

float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

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

Raymarch_Result planet_sdf(vec3 p)
{
	Raymarch_Result res;
	res.color = vec4(1);
	
	float d = sin(p.x / 100.0) * 100;
	d += sin(p.y / 100.0) * 100;
	d += sin(p.z / 100.0) * 100;
	
	d = 0;
	
	float elevation = planet_radius + d;
	
	if (elevation < sea_level)
	{
		elevation = sea_level;
		res.color = vec4(0, 0, 1, 1);
	}
	
	res.dist = length(p) - elevation;
	
	return res; 
}

vec3 planet_normal(vec3 ray)
{
	vec3 n1 =
		vec3(planet_sdf(ray + vec3(eps, 0, 0)).dist, planet_sdf(ray + vec3(0, eps, 0)).dist, planet_sdf(ray + vec3(0, 0, eps)).dist);
	
	vec3 n2 = vec3(planet_sdf(ray - vec3(eps, 0, 0)).dist, planet_sdf(ray - vec3(0, eps, 0)).dist, planet_sdf(ray - vec3(0, 0, eps)).dist);
	
	vec3 normal = normalize(n2 - n1);
	
	return normal;
}

void main()
{
	vec2 p = (gl_FragCoord.xy / u_screen_size) * 2.0 - 1.0;
	
	mat4 cam_to_world = inverse(u_view);
	mat4 clip_to_cam = inverse(u_proj);
	
	vec4 ray_origin = cam_to_world * vec4(0.0, 0.0, 0.0, 1.0);
	vec3 o = ray_origin.xyz;
	
	vec4 clip_pos = vec4(p, -1.0, 1.0);
	vec4 view_pos = clip_to_cam * clip_pos;
	view_pos /= view_pos.w;
	
	vec4 ray_target = cam_to_world * vec4(view_pos.xyz, 0.0);
	
	vec3 d = normalize(ray_target.xyz);
	
	Intersection_Result leap_res = ray_sphere_intersection(o, d, planet_radius + 256);
	
	if (leap_res.hit)
	{
		float pos = 0;
		pos += leap_res.t1;
		for (int i = 0; i < num_steps; i++)
		{
			vec3 ray = o + d * pos;
			Raymarch_Result res = planet_sdf(ray);
			
			if (res.dist < eps)
			{
				vec4 clip_pos = u_proj * u_view * vec4(ray,1);
				gl_FragDepth = (clip_pos.z / clip_pos.w) * 0.5 + 0.5;
				
				vec3 normal = planet_normal(ray);
				vec3 light_dir = normalize(vec3(1,-1,0));
				float diff = dot(normal, light_dir);
				
				out_color = res.color * vec4(diff, diff, diff, 1.0);
				out_color = vec4(normal, 1.0);
				return;
			}
			pos += res.dist;
		}
	}
	else
	{
		//out_color = vec4(1,0,0,1);
	}
}
