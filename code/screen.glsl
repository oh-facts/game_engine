#version 450
#extension GL_ARB_bindless_texture : enable

uniform uvec2 u_color_tex;

@common_shader_end;
out vec2 a_uv;

void main()
{
	vec2 vertices[] =
	{
    {-1.0, -1.0},
    {-1.0,  1.0},
    { 1.0, -1.0},
		
    {-1.0,  1.0},
    { 1.0,  1.0},
    { 1.0, -1.0}
	};
	
	vec2 vertex = vertices[gl_VertexID];
	
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
	
	gl_Position = vec4(vertex, 0, 1);
}

@vertex_shader_end;

in vec2 a_uv;
layout (location=0) out vec4 out_color;

void main()
{
	vec4 tex_color = texture(sampler2D(u_color_tex), a_uv);
	out_color = tex_color;
	//out_color = vec4(1, 0, 0, 1);
}