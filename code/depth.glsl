#version 450 core

@common_shader_end;

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

layout (std430, binding = 0) buffer ssbo2 {
	Vertex vertices[];
};

uniform mat4 u_model;

uniform mat4 u_light_proj_view;

void main()
{
	Vertex v = vertices[gl_VertexID];
	gl_Position = u_light_proj_view * u_model * vec4(v.pos, 1.0);
}

@vertex_shader_end;

void main()
{
	
}