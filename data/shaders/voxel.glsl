#version 450
#extension GL_ARB_bindless_texture : enable

uniform vec2 u_screen_size;
uniform vec3 u_cam_pos;
uniform mat4 u_proj;
uniform mat4 u_view;
uniform float u_time;

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

float sd_sphere(vec3 p, float d) { return length(p) - d; } 

struct Trace_Ray_Data {
	bool hit;
	vec3 normal;
	ivec3 map_pos;
	bvec3 mask;
};

#define MAX_RAY_STEPS 256

float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }
float rand(vec2 co){ return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); }
float rand(vec3 co){ return rand(co.xy+rand(co.z)); }

//#define water_level 30

float water_level_func(vec3 p) {
	return 30.0 + sin(p.x * 0.1 + u_time) * 1.5 + sin(p.z * 0.15 + u_time * 1.2) * 1.5;
}

#define water_level water_level_func(p)

float raw_terrain(vec3 p)
{
	float el = 0;
	el = sin(p.x * 0.06) * 600.0;
	el += sin(p.y * 0.06) * 600.0;
	el += sin(p.z * 0.06) * 600.0;
	return el;
}

float map(vec3 p)
{
	return max(water_level, raw_terrain(p));
}

vec3 calcNormal(vec3 p) {
	float eps = 0.01;
	float h = raw_terrain(p);
	float dx = raw_terrain(p + vec3(eps, 0, 0)) - h;
	float dy = raw_terrain(p + vec3(0, eps, 0)) - h;
	float dz = raw_terrain(p + vec3(0, 0, eps)) - h;
	return normalize(vec3(dx, dy, dz));
}


Trace_Ray_Data trace_ray(vec3 ray_pos, vec3 ray_dir) {
	bool hit = false;
	
	ivec3 map_pos = ivec3(floor(ray_pos + 0.));
	
	vec3 delta_dist = abs(vec3(length(ray_dir)) / ray_dir);
	
	ivec3 ray_step = ivec3(sign(ray_dir));
	
	vec3 side_dist = (sign(ray_dir) * (vec3(map_pos) - ray_pos) + (sign(ray_dir) * 0.5) + 0.5) * delta_dist; 
	
	bvec3 mask = bvec3(false);
	
	Trace_Ray_Data trace_ray_data;
	
	for (int i = 0; i < MAX_RAY_STEPS; i++) {
		
		vec3 p = vec3(map_pos) + vec3(0.5);
		float el = map(p);
		
		if (map_pos.y <= el)
		{
			hit = true;
			break;
		}
		
		mask = lessThanEqual(side_dist.xyz, min(side_dist.yzx, side_dist.zxy));
		side_dist += vec3(mask) * delta_dist;
		map_pos += ivec3(vec3(mask)) * ray_step;
	}
	
	trace_ray_data.hit = hit;
	trace_ray_data.map_pos = map_pos;
	vec3 normal = vec3(mask) * vec3(-ray_step);
	//normal = normalize(normal) * 0.5 + 0.5;
	
	//vec3 normal = calcNormal(map_pos);
	//vec3 normal = getNormal(map_pos.xz);
	
	trace_ray_data.normal = normal;
	trace_ray_data.mask = mask;
	
	return trace_ray_data;
}

void main() {
	
	vec2 p = (gl_FragCoord.xy / u_screen_size) * 2.0 - 1.0;
	
	mat4 cam_to_world = inverse(u_view);
	mat4 clip_to_cam = inverse(u_proj);
	
	vec4 ray_origin = cam_to_world * vec4(0.0, 0.0, 0.0, 1.0);
	vec3 ro = ray_origin.xyz;
	
	vec4 clip_pos = vec4(p, -1.0, 1.0);
	vec4 view_pos = clip_to_cam * clip_pos;
	view_pos /= view_pos.w;
	
	vec4 ray_target = cam_to_world * vec4(view_pos.xyz, 0.0);
	
	vec3 rd = normalize(ray_target.xyz);
	
	Trace_Ray_Data res = trace_ray(ro, rd);
	
	if (res.hit)
	{
		vec4 clip_pos = u_proj * u_view * vec4(res.map_pos,1);
		gl_FragDepth = (clip_pos.z / clip_pos.w) * 0.5 + 0.5;
		
		/*
		float r = rand(res.map_pos);
		float g = rand(res.map_pos + vec3(r));
		float b = rand(res.map_pos + vec3(g));
		*/
		
		vec3 normal = calcNormal(res.map_pos);
		
		vec3 light = normalize(vec3(0, -1, 0));
		float diff = dot(light, normal);
		vec3 dif = vec3(diff);
		
		//vec3 color = vec3(r,g,b) * dif;
		
		vec3 color = vec3(0, 1, 0) * dif;
		
		vec3 p = vec3(res.map_pos) + vec3(0.5);
		float w = water_level_func(p);
		
		if (res.map_pos.y <= w)
		{
			color = vec3(0, 1, 1) * dif;
		}
		
		out_color = vec4(color, 1.0);
	}
}