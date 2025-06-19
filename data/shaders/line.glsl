#version 450
#extension GL_ARB_bindless_texture : enable

uniform mat4 u_view;
uniform mat4 u_proj;

struct Line
{
	vec4 pos;
	vec4 color;
};

layout (std430, row_major, binding = 0) buffer ssbo2 
{
	Line objs[];
};

#define COMMON_SHADER_END

flat out int a_index;
out vec2 a_uv;

void main()
{
	
	Line obj = objs[gl_InstanceID];
	
	gl_Position = u_proj * u_view * vec4(pos.xyz, 1);
	a_index = gl_InstanceID;
}

#define VERTEX_SHADER_END

layout (location=0) out vec4 out_color;
flat in int a_index;
in vec2 a_uv;

void main()
{
	Line obj = objs[a_index];
	out_color = tex_col * obj.color;
}