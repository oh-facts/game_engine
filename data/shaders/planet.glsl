#version 450
#extension GL_ARB_bindless_texture : enable
uniform mat4 u_view;
uniform mat4 u_proj;
uniform vec2 u_screen_size;

#define COMMON_SHADER_END

void main()
{
	vec2 vertices[] = 
	{
		{-1, -3},
		{3, 1},
		{-1, 1},
	};
	
	vec2 vertex = vertices[gl_VertexID];
	gl_Position = vec4(vertex, 0, 1);
}

#define VERTEX_SHADER_END

layout (location=0) out vec4 out_color;

float circle_sdf(vec2 p, float r)
{
	return length(p) - r;
}

float sphere_sdf(vec3 p, float r)
{
	return length(p) - r;
}

void main()
{
	vec2 p = (gl_FragCoord.xy / u_screen_size) * 2.0 - 1.0;
	
	mat4 cam_to_world = inverse(u_view);
	mat4 clip_to_cam = inverse(u_proj);
	
	vec4 ray_origin = cam_to_world * vec4(0.0, 0.0, 0.0, 1.0);
	vec3 o = ray_origin.xyz;
	
#if 1
	vec4 clip_pos = vec4(p, -1.0, 1.0);
	vec4 view_pos = clip_to_cam * clip_pos;
	view_pos /= view_pos.w;
	
	vec4 ray_target = cam_to_world * vec4(view_pos.xyz, 0.0);
	
	vec3 d = normalize(ray_target.xyz);
	
#else
	p.x *= u_screen_size.x / u_screen_size.y;
	
	vec4 ray_target = cam_to_world * vec4(p.x, p.y, -1.0, 1.0);
	
	vec3 d = normalize(ray_target.xyz - o);
#endif
	
	bool hit = false;
	float num_steps = 100;
	vec3 color = vec3(1);
	
	float dist_travelled = 0.0;
	
	for (int i = 0; i < num_steps; i++)
	{
		vec3 ray = o + d * dist_travelled;
		
		float dist = sphere_sdf(ray, 1.0);
		
		if (dist < 0.001)
		{
			vec4 clip_pos = u_proj * u_view * vec4(ray,1);
			gl_FragDepth = (clip_pos.z / clip_pos.w) * 0.5 + 0.5;
			hit = true;
			break;
		}
		
		dist_travelled += dist;
	}
	
	if (hit)
	{
		out_color = vec4(color, 1);
	}
}
