#version 450
#extension GL_ARB_bindless_texture : enable

uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_model;

uniform uvec2 u_shadow_map;
uniform mat4 u_light_proj_view;

uniform vec4 u_color;
uniform uvec2 u_color_map;
uniform uint u_flags;
uniform uint u_base_xform_index;
uniform const bool u_debug = false;

#define Animated (1 << 0)

struct Vertex
{
	vec3 pos;
	float uv_x;
	vec3 normal;
	float uv_y;
	vec4 color;
	vec3 tangent;
	float pad;
	int joints[4];
	float weights[4];
};

layout (std430, binding = 0) buffer ssbo2 
{
	Vertex vertices[];
};

layout (std430, row_major, binding = 1) buffer ssbo3
{
	mat4 joint[];
};

@common_shader_end;

out vec2 a_uv;
out vec3 a_normal;
out vec4 a_frag_pos;
out vec4 a_frag_pos_light_space;

void main()
{
	Vertex v = vertices[gl_VertexID];
	a_uv.x = v.uv_x;
	a_uv.y = v.uv_y;
	a_normal = mat3(transpose(inverse(u_model))) * v.normal;
	a_frag_pos = u_model * vec4(v.pos, 1.0);
	a_frag_pos_light_space = u_light_proj_view * a_frag_pos;
	mat4 skin = mat4(0);
	
	if ((u_flags & Animated) != 0)
	{
		for(int i = 0; i < 4; i++)
		{
			skin += v.weights[i] * joint[v.joints[i] + u_base_xform_index]; 
		}
	}
	else
	{
		skin = mat4(1);
	}
	
	gl_Position = u_proj * u_view * u_model * skin * vec4(v.pos, 1.0);
}

// gl_Position = u_proj * u_view * u_model * vec4(v.pos, 1.0);

@vertex_shader_end;

layout (location=0) out vec4 out_color;
in vec2 a_uv;
in float col[4];
in vec3 a_normal;
in vec4 a_frag_pos;
in vec4 a_frag_pos_light_space;

void main()
{
	vec4 tex_col = texture(sampler2D(u_color_map), a_uv);
	
	vec3 nice_normal = normalize(a_normal) * 0.5 + 0.5;
	
	vec3 light_dir = normalize(vec3(-2, 5, -1));
	float diff = max(dot(normalize(a_normal), light_dir), 0.0) * 0.3;
	vec3 diffuse = vec3(diff);
	vec3 ambient = vec3(0.3);
	
	vec3 proj_coords = a_frag_pos_light_space.xyz / a_frag_pos_light_space.w;
	proj_coords.x = proj_coords.x * 0.5 + 0.5;
	proj_coords.y = proj_coords.y * 0.5 + 0.5;
	
	float shadow = 0.0;
	if (proj_coords.z < 1.0 && proj_coords.z > 0.0)
	{
		shadow = 1.0;
		vec2 poissonDisk[4] = vec2[](
																 vec2( -0.94201624, -0.39906216 ),
																 vec2( 0.94558609, -0.76890725 ),
																 vec2( -0.094184101, -0.92938870 ),
																 vec2( 0.34495938, 0.29387760 )
																 );
		for (int i=0;i<4;i++)
		{
			
			float closest_depth = texture(sampler2D(u_shadow_map), proj_coords.xy + poissonDisk[i] / 700).r;
			float current_depth = proj_coords.z;
			
			float bias = 0.005 * tan(acos(clamp(dot(light_dir, normalize(a_normal)),0, 1)));
			
			if ((current_depth + bias) > closest_depth)
			{
				shadow -= 0.25;
			}
			
		}
	}
	
	vec3 shading = diffuse * (1 - shadow) + ambient;
	
	out_color = u_color * tex_col * vec4(shading, 1.0);
	
	//out_color = vec4(nice_normal, 1);
}