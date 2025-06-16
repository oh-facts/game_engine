#version 450
#extension GL_ARB_bindless_texture : enable

uniform mat4 u_view;
uniform mat4 u_proj;

struct Rect
{
	vec2 tl;
	vec2 br;
};

struct R_Rect2
{
	mat4 model;
	vec4 color;
	uvec2 tex_id;
	uvec2 pad;
};

layout (std430, row_major, binding = 0) buffer ssbo2 
{
	R_Rect2 rects[];
};

#define COMMON_SHADER_END

flat out int a_index;
out vec2 a_uv;

void main()
{
	R_Rect2 obj = rects[gl_InstanceID];
	
	vec2 vertices[] =
	{
    {-1.0, -1.0},
    {-1.0,  1.0},
    { 1.0, -1.0},
		
    {-1.0,  1.0},
    { 1.0,  1.0},
    { 1.0, -1.0}
	};
	
	vec2 base_uv[] = 
	{
    {0, 0},
    {0, 1},
    {1, 0},
		
    {0, 1},
    {1, 1},
    {1, 0}
	};
	
	a_uv = base_uv[gl_VertexID];
	
	vec2 vertex = vertices[gl_VertexID];
	vertex.x /= 2;
	vertex.y /= 2;
	
	gl_Position = u_proj * u_view * obj.model * vec4(vertex, 0, 1);
	a_index = gl_InstanceID;
}

#define VERTEX_SHADER_END

layout (location=0) out vec4 out_color;
flat in int a_index;
in vec2 a_uv;

void main()
{
	R_Rect2 obj = rects[a_index];
	vec4 tex_col = texture(sampler2D(obj.tex_id), a_uv);
	
	//if (tex_col.a < 0.01) discard;
	
	//vec3 color = pow(tex_col.xyz, vec3(1.0 / 2.2));
	//out_color  = vec4(color, tex_col.a);
	out_color = tex_col * obj.color;
}