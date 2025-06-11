#version 450
#extension GL_ARB_bindless_texture : enable

uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_model;
uniform vec4 u_color;
uniform uvec2 u_color_map;
uniform uint u_flags;
uniform uint u_base_xform_index;

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

#define COMMON_SHADER_END

out vec2 a_uv;
out vec3 a_normal;

void main()
{
	Vertex v = vertices[gl_VertexID];
	a_uv.x = v.uv_x;
	a_uv.y = v.uv_y;
	a_normal = mat3(transpose(inverse(u_model))) * v.normal;;
	
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

#define VERTEX_SHADER_END

layout (location=0) out vec4 out_color;
in vec2 a_uv;
in float col[4];
in vec3 a_normal;

void main()
{
	vec4 tex_col = texture(sampler2D(u_color_map), a_uv);
	out_color = u_color * tex_col;
	
	vec3 nice_normal = normalize(a_normal) * 0.5 + 0.5;
	//out_color = vec4(nice_normal, 1);
	//out_color = vec4(0, 1, 0, 1);
}