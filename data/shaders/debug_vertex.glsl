#version 450
#extension GL_ARB_bindless_texture : enable

uniform mat4 u_view;
uniform mat4 u_proj;

struct Debug_Vertex
{
	vec4 pos;
	vec4 color;
};

layout (std430, row_major, binding = 0) buffer ssbo2 
{
	Debug_Vertex objs[];
};

#define COMMON_SHADER_END

flat out int a_index;

void main()
{
	Debug_Vertex obj = objs[gl_VertexID];
	
	gl_Position = u_proj * u_view * vec4(obj.pos.xyz, 1);
	a_index = gl_VertexID;
}

#define VERTEX_SHADER_END

layout (location=0) out vec4 out_color;
flat in int a_index;

void main()
{
	Debug_Vertex obj = objs[a_index];
	out_color = obj.color;
}