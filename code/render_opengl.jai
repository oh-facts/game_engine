// Make ssbos size based ?

VF_Shaders :: enum 
{
	Sprite;
	Count;
}

Instance_Buffers :: enum 
{
	Sprite;
	Count;
}

R_GL_Image :: struct 
{
	id : GLuint;
	resident : GLuint64;
	w : int;
	h : int;
};

vf_shader_paths :[VF_Shaders.Count]string: .["sprite"];

R_GL_State :: struct 
{
	arena : *Arena;
	white_square : Handle;
	base_path : string;
	shaders_folder : string;
	
	vf_shaders : [VF_Shaders.Count]GLuint;
	inst_buffers : [Instance_Buffers.Count]GLuint;
}

r_gl_state : *R_GL_State;

r_init :: () 
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
	
	r_gl_state.base_path = path_strip_filename(get_path_of_running_executable());
	r_gl_state.shaders_folder = join(r_gl_state.base_path, "../shaders");
	
	compile_shaders();
	
	for 0 .. Instance_Buffers.Count - 1 
	{
		r_gl_state.inst_buffers[it] = make_ssbo(MB(8));
	}
	
	data : [1]s64 : .[0xFFFFFFFF];
	
	r_gl_state.white_square = r_image_create(1, 1, 4, xx data.data, GL_NEAREST);
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

r_image_create :: (w : s32, h : s32, n : s32, bytes : *u8, params : Tex_Params) -> Handle
{
	img : *R_GL_Image;
	
	if params == .Linear {
		img = r_gl_image_create(w, h, n, bytes, GL_LINEAR);
	} else {
		img = r_gl_image_create(w, h, n, bytes, GL_NEAREST);
	}
	
	out : Handle;
	out.U64[0] = xx img;
	
	return out;
}

r_gl_image_create :: (w : s32, h : s32, n : s32, bytes : *u8, params : GLint) -> *R_GL_Image
{
	img : *R_GL_Image = push_struct(r_gl_state.arena, R_GL_Image);
	
	<< img = .{};
	
	id : GLuint;
	glCreateTextures(GL_TEXTURE_2D, 1, *id);
	
	glTextureParameteri(id, GL_TEXTURE_MIN_FILTER, params);
	glTextureParameteri(id, GL_TEXTURE_MAG_FILTER, params);
	
	glTextureStorage2D(id, 1, GL_RGBA32F, xx w, xx h);
	
	if bytes 
	{
		glTextureSubImage2D(id, 0, 0, 0, xx w, xx h, GL_RGBA, GL_UNSIGNED_BYTE, bytes);
	}
	
	glTextureParameteri(id, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTextureParameteri(id, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	resident := glGetTextureHandleARB(id);
	glMakeTextureHandleResidentARB(resident);
	
	img.id = id;
	img.resident = resident;
	img.w = w;
	img.h = h;
	
	return img;
}

uvec2_from_u64 :: (v : u64) -> u32, u32 
{
	l : u32 = cast(u32) (v & 0xFFFFFFFF); 
	r: u32 = cast(u32) (v >> 32);
	
	return l, r;
}

r_submit :: (pb : R_Push_Buffer)
{
	
	glViewport(0, 0, xx pb.viewport.x, xx pb.viewport.y);
	
	glClearColor(0.2, 0.2, 0.3, 1.0);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	// sprite batches
	{
		buffer := r_gl_state.inst_buffers[Instance_Buffers.Sprite];
		shader := r_gl_state.vf_shaders[VF_Shaders.Sprite];
		
		glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, buffer);
		glUseProgram(shader);
		
		proj_loc := glGetUniformLocation(shader, "u_proj");
		view_loc := glGetUniformLocation(shader, "u_view");
		
		glUniformMatrix4fv(view_loc, 1, GL_TRUE, *pb.view.coef[0][0]);
		glUniformMatrix4fv(proj_loc, 1, GL_TRUE, *pb.proj.coef[0][0]);
		
		batches := pb.sprite_batches;
		batch := batches.first;
		
		while batch
		{
			ssbo_data : *u8 = glMapNamedBufferRange(buffer, 0, batch.size, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
			
			memcpy(ssbo_data, batch.base, batch.size);
			
			glUnmapNamedBuffer(buffer);
			
			glDrawArraysInstanced(GL_TRIANGLES, 0, 6, batch.count);
			
			batch = batch.next;
		}
	}
	
}

make_ssbo :: (size : u64) -> GLuint 
{
	ssbo : GLuint;
	glCreateBuffers(1, *ssbo);
	glNamedBufferData(ssbo, xx size, xx 0, GL_STREAM_DRAW);
	
	return ssbo;
}

compile_shaders :: () 
{
	for 0 .. VF_Shaders.Count - 1 
	{
		abs_path := tprint("%/%.glsl", r_gl_state.shaders_folder, vf_shader_paths[it]);
		
		shader_file := read_entire_file(abs_path, true);
		defer free(shader_file);
		
		found, left, right := split_from_left(shader_file, "#define COMMON_SHADER_END");
		
		common_shader_text := left;
		
		found, left, right = split_from_left(right, "#define VERTEX_SHADER_END");
		
		vertex_shader_text := left;
		
		fragment_shader_text := right;
		
		combined_vertex_shader_text := tprint("%0%", common_shader_text, vertex_shader_text);
		combined_fragment_shader_text := tprint("%0%", common_shader_text, fragment_shader_text);
		
		r_gl_state.vf_shaders[it] = make_shader_program(combined_vertex_shader_text, combined_fragment_shader_text);
	}
}

check_compile_errors :: (shader : GLuint, type : *u8) 
{
	success : s32;
	infoLog: [1024]u8;
	
	glGetShaderiv(shader, GL_COMPILE_STATUS, *success);
	if !success {
		glGetShaderInfoLog(shader, 1024, xx 0, xx infoLog.data);
		print("% compilation error:\n%\n", to_string(type), to_string(infoLog.data));
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
	
	check_compile_errors(vert_shader, "vertex shader");
	
	frag_shader := glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(frag_shader, 1, *(fragmentShaderSource.data), xx 0);
	glCompileShader(frag_shader);
	check_compile_errors(frag_shader, "fragment shader");
	
	shader_prog := glCreateProgram();
	glAttachShader(shader_prog, vert_shader);
	glAttachShader(shader_prog, frag_shader);
	
	glLinkProgram(shader_prog);
	check_link_errors(shader_prog, "vert/frag shader");
	
	glDeleteShader(vert_shader);
	glDeleteShader(frag_shader);
	
	return shader_prog;
}