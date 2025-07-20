// Make ssbos size based ?

Instance_Buffers :: enum 
{
	Sprite;
	Debug_Vertex;
	Count;
}

R_GL_Image :: struct 
{
	next : *R_GL_Image;
	id : GLuint;
	resident : GLuint64;
	w : int;
	h : int;
};

VF_Shader_Kind :: enum 
{
	Sprite;
	Mesh;
	Debug_Vertex;
	Planet;
	Voxel;
	Screen;
	Count;
}

R_GL_Framebuffer :: struct
{
	color_texture : *R_GL_Image;
	depth_stencil_texture : *R_GL_Image;
	id : GLuint;
}

r_gl_framebuffer_create :: (fb_size : Vector2i) -> R_GL_Framebuffer
{
	using out : R_GL_Framebuffer;
	
	glCreateFramebuffers(1, *id);
	
	color_texture = r_gl_image_create(fb_size.x, fb_size.y, GL_RGBA32F, null, GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE);
	glNamedFramebufferTexture(id, GL_COLOR_ATTACHMENT0, color_texture.id, 0);
	
	depth_stencil_texture = r_gl_image_create(fb_size.x, fb_size.y, GL_DEPTH32F_STENCIL8, null, GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE);
	
	glNamedFramebufferTexture(id, GL_DEPTH_STENCIL_ATTACHMENT, depth_stencil_texture.id, 0);
	
	fb_status := glCheckNamedFramebufferStatus(id, GL_FRAMEBUFFER);
	
	if fb_status != GL_FRAMEBUFFER_COMPLETE
	{
		assert(false, "framebuffer incomplete or something, error %", fb_status);
	}
	
	return out;
}

r_gl_framebuffer_free :: (fb : R_GL_Framebuffer)
{
	glDeleteFramebuffers(1, *fb.id);
	
	r_gl_image_free(fb.color_texture);
	r_gl_image_free(fb.depth_stencil_texture);
}

R_GL_State :: struct 
{
	// shader kind is implicit.
	// array index in the vf_shaders array
	Shader :: struct
	{
		path : string;
		id : GLuint;
		init : bool;
	}
	
	arena : *Arena;
	white_square : Handle;
	
	vf_shaders : [VF_Shader_Kind.Count]Shader;
	inst_buffers : [Instance_Buffers.Count]GLuint;
	
	skinning_transforms : GLuint;
	draw_fb : R_GL_Framebuffer;
	
	free_image : *R_GL_Image;
	last_draw_size : Vector2i;
}

r_gl_state : *R_GL_State;

r_buffer_create :: (hint : Buffer_Hint, data : *void, size : u64) -> GLuint
{
	ssbo : GLuint;
	glCreateBuffers(1, *ssbo);
	
	gl_hint : u32;
	
	if hint == {
		case .Static_Draw;
		gl_hint = GL_STATIC_DRAW;
		case .Dynamic_Draw;
		gl_hint = GL_DYNAMIC_DRAW;
	}
	
	glNamedBufferData(ssbo, xx size, data, gl_hint);
	
	return ssbo;
}

get_white_square :: () -> Handle
{
	return r_gl_state.white_square;
}

tex_id_from_handle :: (h : Handle) -> u64
{
	image : *R_GL_Image = xx h.U64[0];
	return image.resident;
}

tex_size_from_handle :: (h : Handle) -> Vector2
{
	image : *R_GL_Image = xx h.U64[0];
	return .{xx image.w, xx image.h};
}

r_image_create :: (w : s32, h : s32, n : s32, bytes : *u8, min_filter : Tex_Param,
									 mag_filter : Tex_Param,
									 wrap : Tex_Param) -> Handle
{
	img : *R_GL_Image;
	
	gl_min_filter, gl_mag_filter, gl_wrap : GLint;
	
	gl_param_from_tex_param_table : []GLint =
		.[
			GL_NEAREST,
			GL_LINEAR,
			GL_NEAREST_MIPMAP_NEAREST,
			GL_LINEAR_MIPMAP_NEAREST,
			GL_NEAREST_MIPMAP_LINEAR,
			GL_LINEAR_MIPMAP_LINEAR,
			GL_CLAMP_TO_BORDER,
			GL_REPEAT,
			];
	
	gl_min_filter = gl_param_from_tex_param_table[xx min_filter];
	
	gl_mag_filter = gl_param_from_tex_param_table[xx mag_filter];
	
	gl_wrap = gl_param_from_tex_param_table[xx wrap];
	
	img = r_gl_image_create(w, h, GL_RGBA32F, bytes, gl_min_filter, gl_mag_filter, gl_wrap);
	
	out : Handle;
	out.U64[0] = xx img;
	
	return out;
}

hmap : u64;
mountain_map : u64;

r_backend_init :: (fb_size : Vector2i) 
{
	gl_create_context(the_window, 4, 6);
	gl_load(*gl);
	
	print ("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
	print ("GL Version = %\n", to_string(glGetString(GL_VERSION)));
	
	arena := arena_init(MB(32), MB(32));
	r_gl_state = push_struct(arena, R_GL_State);
	r_gl_state.arena = arena;
	
	stupid_fucking_opengl : GLuint;
	glCreateVertexArrays(1, *stupid_fucking_opengl);
	glBindVertexArray(stupid_fucking_opengl);
	
	glEnable(GL_DEBUG_OUTPUT);
	glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS); 
	
	
	gl_enable_debug_output(true);
	// init shaders
	{
		init_shader(.Sprite, "sprite");
		init_shader(.Mesh, "mesh");
		init_shader(.Debug_Vertex, "debug_vertex");
		//init_shader(.Planet, "planet");
		//init_shader(.Voxel, "voxel");
		init_shader(.Screen, "screen");
	}
	
	compile_shaders();
	//glEnable(GL_FRAMEBUFFER_SRGB);
	
	for 0 .. Instance_Buffers.Count - 1 
	{
		r_gl_state.inst_buffers[it] = r_buffer_create(.Dynamic_Draw, xx 0, MB(8));
	}
	
	r_gl_state.skinning_transforms = r_buffer_create(.Dynamic_Draw, xx 0, MB(8));
	
	data : [1]s64 : .[0xFFFFFFFF];
	
	r_gl_state.white_square = r_image_create(1, 1, 4, xx data.data, .Nearest, .Nearest, .Repeat);
	
	if false
	{
		{
			data := read_entire_file(tprint("%/noise.png", data_folder));
			hmap = tex_id_from_handle(image_create_from_memory(data, .Linear, .Linear, .Repeat));
		}
		
		{
			data := read_entire_file(tprint("%/mountain.png", data_folder));
			mountain_map = tex_id_from_handle(image_create_from_memory(data, .Linear, .Linear, .Repeat));
		}
	}
	
	// init draw framebuffer
	r_gl_state.draw_fb = r_gl_framebuffer_create(fb_size);
	r_gl_state.last_draw_size = fb_size;
}

r_submit :: (pb : R_Push_Buffer, draw_size : Vector2i)
{
	profile_scope("Render Submission");
	
	if draw_size != r_gl_state.last_draw_size
	{
		r_gl_framebuffer_free(r_gl_state.draw_fb);
		r_gl_state.draw_fb = r_gl_framebuffer_create(draw_size);
	}
	
	glBindFramebuffer(GL_FRAMEBUFFER, r_gl_state.draw_fb.id);
	glViewport(xx pb.viewport.min.x, xx pb.viewport.min.y, xx pb.viewport.size.x, xx pb.viewport.size.y);
	glScissor(xx pb.viewport.min.x, xx pb.viewport.min.y, xx pb.viewport.size.x, xx pb.viewport.size.y);
	
	glClearColor(0.2, 0.2, 0.3, 1.0);
	
	glEnable(GL_DEPTH_TEST);
	glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);
	glClearDepth(0.0);
	glDepthFunc(GL_GREATER);
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_SCISSOR_TEST);
	
	//glPointSize(12.0);
	
	if pb.hacker_draw
	{
		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	}
	else
	{
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}
	
	glEnable(GL_CULL_FACE);
	
	// 3d meshes
	if pb.mesh_batches.count
	{
		shader := r_gl_state.vf_shaders[VF_Shader_Kind.Mesh];
		
		glUseProgram(shader.id);
		
		proj_loc := glGetUniformLocation(shader.id, "u_proj");
		view_loc := glGetUniformLocation(shader.id, "u_view");
		model_loc := glGetUniformLocation(shader.id, "u_model");
		color_loc := glGetUniformLocation(shader.id, "u_color");
		color_map_loc := glGetUniformLocation(shader.id, "u_color_map");
		flags_loc := glGetUniformLocation(shader.id, "u_flags");
		base_xform_loc := glGetUniformLocation(shader.id, "u_base_xform_index");
		debug_loc := glGetUniformLocation(shader.id, "u_debug");
		
		glUniformMatrix4fv(view_loc, 1, GL_TRUE, *pb.view.coef[0][0]);
		glUniformMatrix4fv(proj_loc, 1, GL_TRUE, *pb.proj.coef[0][0]);
		glUniform1i(debug_loc, xx pb.hacker_draw);
		
		// do skinning if needed
		if pb.skinning_xforms.count
		{
			glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, r_gl_state.skinning_transforms);
			
			buffer := r_gl_state.skinning_transforms;
			
			xform_size := pb.skinning_xforms.first.size;
			xforms := pb.skinning_xforms.first.base;
			
			ssbo_data : *u8 = glMapNamedBufferRange(buffer, 0, xx xform_size, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
			
			memcpy(ssbo_data, xforms, xx xform_size);
			
			glUnmapNamedBuffer(buffer);
		}
		
		// draw meshes
		{
			batches := pb.mesh_batches;
			batch := batches.first;
			
			while batch
			{
				meshes : *R_Mesh = xx batch.base;
				
				for 0 .. batch.count - 1 
				{
					mesh := meshes + it;
					glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, mesh.vertex_buffer);
					glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.index_buffer);
					glUniformMatrix4fv(model_loc, 1, GL_TRUE, *mesh.xform.coef[0][0]);
					glUniform4fv(color_loc, 1, *mesh.color.component[0]);
					glUniform1ui(flags_loc, cast, force(u32)mesh.flags);
					
					l, r := uvec2_from_u64(mesh.color_map);
					glUniform2ui(color_map_loc, l, r);
					
					if mesh.flags & .Animated
					{
						xform_batch :*Matrix4= xx mesh.skinning_xform_batch.base;
						xform_base := mesh.base_skinning_xform;
						
						xform_index :u32= xx (xform_base - xform_batch);
						
						glUniform1ui(base_xform_loc, xform_index);
						ooga : int;
					}
					
					glDrawElements(GL_TRIANGLES, mesh.count, GL_UNSIGNED_INT, xx (mesh.start * size_of(u32)));
				}
				
				batch = batch.next;
			}
		}
	}
	
	// debug vertex / line batches
	if pb.debug_lines.count || pb.debug_vertices.count 
	{
		buffer := r_gl_state.inst_buffers[Instance_Buffers.Debug_Vertex];
		shader := r_gl_state.vf_shaders[VF_Shader_Kind.Debug_Vertex];
		
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, buffer);
		glUseProgram(shader.id);
		
		proj_loc := glGetUniformLocation(shader.id, "u_proj");
		view_loc := glGetUniformLocation(shader.id, "u_view");
		
		glUniformMatrix4fv(view_loc, 1, GL_TRUE, *pb.view.coef[0][0]);
		glUniformMatrix4fv(proj_loc, 1, GL_TRUE, *pb.proj.coef[0][0]);
		
		// vertex batches
		if pb.debug_vertices.count 
		{
			batches := pb.debug_vertices;
			batch := batches.first;
			
			while batch
			{
				ssbo_data : *u8 = glMapNamedBufferRange(buffer, 0, batch.size, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
				
				memcpy(ssbo_data, batch.base, batch.size);
				
				glUnmapNamedBuffer(buffer);
				
				glDrawArrays(GL_POINTS, 0, batch.count);
				
				batch = batch.next;
			}
		}
		
		// line batches
		if pb.debug_lines.count
		{
			batches := pb.debug_lines;
			batch := batches.first;
			
			while batch
			{
				ssbo_data : *u8 = glMapNamedBufferRange(buffer, 0, batch.size, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
				
				memcpy(ssbo_data, batch.base, batch.size);
				
				glUnmapNamedBuffer(buffer);
				
				// batch.count * 2 because each vertex pair is considered one "count"
				glDrawArrays(GL_LINES, 0, batch.count * 2);
				
				batch = batch.next;
			}
		}
	}
	
	// world test sandbox thing
	if false
	{
		shader := r_gl_state.vf_shaders[VF_Shader_Kind.Planet];
		glUseProgram(shader.id);
		
		proj_loc := glGetUniformLocation(shader.id, "u_proj");
		view_loc := glGetUniformLocation(shader.id, "u_view");
		
		screen_size_loc := glGetUniformLocation(shader.id, "u_screen_size");
		
		glUniformMatrix4fv(view_loc, 1, GL_TRUE, *pb.view.coef[0][0]);
		glUniformMatrix4fv(proj_loc, 1, GL_TRUE, *pb.proj.coef[0][0]);
		
		glUniform2fv(screen_size_loc, 1, pb.viewport.size.component.data);
		
		glDrawArrays(GL_TRIANGLES, 0, 3);
	}
	
	// voxel sandbox thing
	if false
	{
		shader := r_gl_state.vf_shaders[VF_Shader_Kind.Voxel];
		glUseProgram(shader.id);
		
		proj_loc := glGetUniformLocation(shader.id, "u_proj");
		view_loc := glGetUniformLocation(shader.id, "u_view");
		time_loc := glGetUniformLocation(shader.id, "u_time");
		
		screen_size_loc := glGetUniformLocation(shader.id, "u_screen_size");
		
		glUniformMatrix4fv(view_loc, 1, GL_TRUE, *pb.view.coef[0][0]);
		glUniformMatrix4fv(proj_loc, 1, GL_TRUE, *pb.proj.coef[0][0]);
		glUniform1fv(time_loc, 1, *pb.counter);
		glUniform2fv(screen_size_loc, 1, pb.viewport.size.component.data);
		
		glDrawArrays(GL_TRIANGLES, 0, 3);
	}
	
	glDisable(GL_CULL_FACE);
	
	// 3d ui batches
	
	if pb.quad_lists.count
	{
		buffer := r_gl_state.inst_buffers[Instance_Buffers.Sprite];
		shader := r_gl_state.vf_shaders[VF_Shader_Kind.Sprite];
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, buffer);
		glUseProgram(shader.id);
		
		proj_loc := glGetUniformLocation(shader.id, "u_proj");
		view_loc := glGetUniformLocation(shader.id, "u_view");
		
		glUniformMatrix4fv(view_loc, 1, GL_TRUE, *pb.view.coef[0][0]);
		glUniformMatrix4fv(proj_loc, 1, GL_TRUE, *pb.proj.coef[0][0]);
		
		batches := pb.quad_lists.first;
		
		while batches
		{
			batch := batches.first;
			
			while batch
			{
				ssbo_data : *u8 = glMapNamedBufferRange(buffer, 0, batch.size, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
				
				memcpy(ssbo_data, batch.base, batch.size);
				
				glUnmapNamedBuffer(buffer);
				
				glDrawArraysInstanced(GL_TRIANGLES, 0, 6, batch.count);
				
				batch = batch.next;
			}
			batches = batches.next;
		}
	}
	
	glEnable(GL_CULL_FACE);
	
	// ui batches
	if pb.sprite_lists.count 
	{
		glDisable(GL_DEPTH_TEST);
		buffer := r_gl_state.inst_buffers[Instance_Buffers.Sprite];
		shader := r_gl_state.vf_shaders[VF_Shader_Kind.Sprite];
		
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, buffer);
		glUseProgram(shader.id);
		
		proj_loc := glGetUniformLocation(shader.id, "u_proj");
		view_loc := glGetUniformLocation(shader.id, "u_view");
		
		batches := pb.sprite_lists.first;
		
		while batches
		{
			glUniformMatrix4fv(view_loc, 1, GL_TRUE, *batches.params.view.coef[0][0]);
			glUniformMatrix4fv(proj_loc, 1, GL_TRUE, *batches.params.proj.coef[0][0]);
			
			// bottom left -> top left
			{
				scissor_origin := batches.params.scissor.min;
				scissor_origin.y = pb.viewport.size.y - scissor_origin.y - batches.params.scissor.size.y;
				
				glScissor(xx scissor_origin.x, xx scissor_origin.y, xx batches.params.scissor.size.x, xx batches.params.scissor.size.y);
			}
			
			batch := batches.first;
			while batch
			{
				ssbo_data : *u8 = glMapNamedBufferRange(buffer, 0, batch.size, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
				
				memcpy(ssbo_data, batch.base, batch.size);
				
				glUnmapNamedBuffer(buffer);
				
				glDrawArraysInstanced(GL_TRIANGLES, 0, 6, batch.count);
				
				batch = batch.next;
			}
			batches = batches.next;
		}
	}
	
	// copy to screen
	{
		glDisable(GL_DEPTH_TEST);
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glDisable(GL_CULL_FACE);
		
		glClearColor(1, 0, 0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
		
		glViewport(xx pb.viewport.min.x, xx pb.viewport.min.y, xx pb.viewport.size.x, xx pb.viewport.size.y);
		glScissor(xx pb.viewport.min.x, xx pb.viewport.min.y, xx pb.viewport.size.x, xx pb.viewport.size.y);
		shader := r_gl_state.vf_shaders[VF_Shader_Kind.Screen];
		
		glUseProgram(shader.id);
		
		color_tex_loc := glGetUniformLocation(shader.id, "u_color_tex");
		
		{
			l, r := uvec2_from_u64(r_gl_state.draw_fb.color_texture.resident);
			glUniform2ui(color_tex_loc, l, r);
		}
		
		glDrawArrays(GL_TRIANGLES, 0, 6);
	}
	
	r_gl_state.last_draw_size = draw_size;
}

r_gl_image_create :: (w : s32, h : s32, format : GLuint, bytes : *u8, min_filter : GLint,
											mag_filter : GLint,
											wrap  : GLint) -> *R_GL_Image
{
	img := r_gl_state.free_image;
	
	if img 
	{
		r_gl_state.free_image = img.next; 
	}
	else
	{
		img = push_struct(r_gl_state.arena, R_GL_Image);
	}
	
	<< img = .{};
	
	id : GLuint;
	glCreateTextures(GL_TEXTURE_2D, 1, *id);
	
	glTextureParameteri(id, GL_TEXTURE_MIN_FILTER, min_filter);
	glTextureParameteri(id, GL_TEXTURE_MAG_FILTER, mag_filter);
	
	glTextureStorage2D(id, 1, format, xx w, xx h);
	
	if bytes 
	{
		glTextureSubImage2D(id, 0, 0, 0, xx w, xx h, GL_RGBA, GL_UNSIGNED_BYTE, bytes);
	}
	
	glTextureParameteri(id, GL_TEXTURE_WRAP_S, wrap);
	glTextureParameteri(id, GL_TEXTURE_WRAP_T, wrap);
	borderColor :  [] float= .[0.0, 0.0, 0.0, 0.0];
	
	glTextureParameterfv(id, GL_TEXTURE_BORDER_COLOR, *borderColor[0]);
	glGenerateTextureMipmap(id);
	
	resident := glGetTextureHandleARB(id);
	glMakeTextureHandleResidentARB(resident);
	
	img.id = id;
	img.resident = resident;
	img.w = w;
	img.h = h;
	
	return img;
}

r_gl_image_free :: (image : *R_GL_Image)
{
	glMakeTextureHandleNonResidentARB(image.resident);
	glDeleteTextures(1, *image.id);
	image.next = r_gl_state.free_image;
	r_gl_state.free_image = image;
}

uvec2_from_u64 :: (v : u64) -> u32, u32 
{
	l : u32 = cast(u32) (v & 0xFFFFFFFF); 
	r : u32 = cast(u32) (v >> 32);
	
	return l, r;
}

init_shader :: (kind : VF_Shader_Kind, path : string)
{
	r_gl_state.vf_shaders[kind].path = path;
	r_gl_state.vf_shaders[kind].init = true;
}

compile_shaders :: () 
{
	for *r_gl_state.vf_shaders 
	{
		if !it.init continue;
		
		abs_path := tprint("%/%.glsl", code_folder, it.path);
		
		shader_file := read_entire_file(abs_path, true);
		defer free(shader_file);
		
		found, left, right := split_from_left(shader_file, "@common_shader_end;");
		
		common_shader_text := left;
		
		found, left, right = split_from_left(right, "@vertex_shader_end;");
		
		vertex_shader_text := left;
		
		fragment_shader_text := right;
		
		combined_vertex_shader_text := tprint("%0%\0", common_shader_text, vertex_shader_text);
		combined_fragment_shader_text := tprint("%0%\0", common_shader_text, fragment_shader_text);
		
		it.id = make_shader_program(combined_vertex_shader_text, combined_fragment_shader_text);
	}
}

check_compile_errors :: (shader : GLuint, code : string) 
{
	success : s32;
	infoLog: [1024]u8;
	
	glGetShaderiv(shader, GL_COMPILE_STATUS, *success);
	if !success {
		glGetShaderInfoLog(shader, 1024, xx 0, xx infoLog.data);
		print("% compilation error:\n%\n", code, to_string(infoLog.data));
		assert(false);
	}
}

check_link_errors :: (shader : GLuint, type : *u8) 
{
	success : s32;
	infoLog : [1024]u8;
	glGetProgramiv(shader, GL_LINK_STATUS, *success);
	if !success {
		glGetProgramInfoLog(shader, 1024, xx 0, xx infoLog.data);
		print("% linking error:\n%\n", to_string(type), to_string(infoLog.data));
		assert(false);
	}
}

make_shader_program :: (vertexShaderSource : string, fragmentShaderSource : string) -> GLuint 
{
	vert_shader := glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vert_shader, 1, *(vertexShaderSource.data), xx 0);
	glCompileShader(vert_shader);
	
	check_compile_errors(vert_shader, vertexShaderSource);
	
	frag_shader := glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(frag_shader, 1, *(fragmentShaderSource.data), xx 0);
	glCompileShader(frag_shader);
	check_compile_errors(frag_shader, fragmentShaderSource);
	
	shader_prog := glCreateProgram();
	glAttachShader(shader_prog, vert_shader);
	glAttachShader(shader_prog, frag_shader);
	
	glLinkProgram(shader_prog);
	check_link_errors(shader_prog, "vert/frag shader");
	
	glDeleteShader(vert_shader);
	glDeleteShader(frag_shader);
	
	return shader_prog;
} 
