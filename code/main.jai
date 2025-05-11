#import "Basic";
#import "System";
#import "String";
#import "Math";
#import "File";
#import "File_Utilities";
#import "IntroSort";
#import "Random";
#import "Thread";
#import "Compiler";
#import "stb_image";
#import "Window_Creation";
#import "Input";
#import "Windows";
#import "Math";

#import "GL" (ENABLE_ALL_EXTENSIONS = true);

#load "base.jai";
#load "render_opengl.jai";
#load "render.jai";

counter : float;

the_window: Window_Type;

exe_folder : string;
art_folder : string;

main :: ()
{
	print("Do not enter is written on the doorway, why can't everyone just go away\n");
	print("Except for you, you can stay\n");
	
	SetProcessDPIAware();
	
	the_window = create_window(960, 540, "The Sad Debugger");
	
	exe_folder = path_strip_filename(get_path_of_running_executable());
	art_folder = join(exe_folder, "../art");
	
	delta : float;
	time_elapsed : float;
	
	start := get_perf_counter();
	freq := get_perf_freq();
	
	r_init();
	
	quit := false;
	
	game : Game;
	
	while !quit 
	{
		counter += delta;
		
		time_since_last := time_elapsed;
		
		update_window_events();
		
		for events_this_frame 
		{
			if it.type == .QUIT then quit = true;
			
			if it.type == .KEYBOARD 
			{
				if it.key_pressed == 0 continue;
				
				if it.key_code == .ESCAPE 
				{
					quit = true;
				}
			}
		}
		
		pb : R_Push_Buffer;
		update_game(*game, *pb, delta);
		r_submit(pb);
		
		dc := GetDC(the_window);
		SwapBuffers(dc);
		
		end := get_perf_counter();
		time_elapsed = (end - start) / (freq * 1.);
		delta = time_elapsed - time_since_last;
		
		reset_temporary_storage();
	}
	
	print("quit safely\n");
}

mouse_delta : Vector2;
position : Vector3 = .{0, 0, -1};
rotation_input : Vector2;
euler_angles : Vector3;

is_key_down :: inline (key : Key_Code) -> bool #must 
{
	return (input_button_states[cast (s64) key] & .DOWN) != 0;
}

is_key_pressed :: inline (key : Key_Code) -> bool #must 
{
	return (input_button_states[cast (s64) key] & .START) != 0;
}

cursor_hidden : bool;

toggle_cursor :: (show : s32) 
{
	count := ShowCursor(show);
	if show {
		while (count < 0) count = ShowCursor(1);
	} else {
		while (count >= 0) count = ShowCursor(0);
	}
}

get_window_size :: (win : Window_Type) -> Vector2 
{
	out : Vector2;
	rect, rect2 : RECT;
	GetClientRect(win, *rect);
	out.x = xx (rect.right - rect.left);
	out.y = xx (rect.bottom - rect.top);
	
	return out;
}

cmt : u64;
res : u64;

reserve :: (size : u64) -> *void 
{
	out := VirtualAlloc(xx 0, size, MEM_RESERVE, PAGE_READWRITE);
	assert(xx out);
	return xx out;
}

commit :: (ptr : *void, size : u64) -> bool 
{
	out := VirtualAlloc(ptr, size, MEM_COMMIT, PAGE_READWRITE);
	assert(xx out);
	return xx out;
}

decommit :: (ptr : *void, size : u64) 
{
	VirtualFree(ptr, size, MEM_DECOMMIT);
}

release :: (ptr : *void, size : u64) 
{
	VirtualFree(ptr, 0, MEM_RELEASE);
}

get_page_size :: () -> u64 
{
	sysinfo : SYSTEM_INFO;
	GetSystemInfo(*sysinfo);
	return sysinfo.dwPageSize;
}

get_perf_counter :: () -> s64 
{
	counter : s64;
	QueryPerformanceCounter(*counter);
	return counter;
}

get_perf_freq :: () -> s64 
{
	frequency : s64;
	QueryPerformanceFrequency(*frequency);
	return frequency;
}

sleep :: (ms : s32) 
{
	Sleep(ms);
}

Entity_Kind :: enum
{
	None;
	World;
	Yk;
	Impolo;
	Tree;
}

Entity_Layer :: enum
{
	Bg;
	Fg;
}

Entity :: struct
{
	kind : Entity_Kind;
	pos : Vector2;
	layer : Entity_Layer;
	color : Vector4;
	rot : float;
}

Game :: struct
{
	initialized : bool;
	arena : *Arena;
	entities : *Entity;
	entity_count : int;
	entity_cap :: 256;
	entity_sort_list : [..]*Entity;
	
	camera : Camera;
	
	yk_tex : Handle;
	world_tex : Handle;
	impolo_idle_tex : Handle;
	tree_tex : Handle;
	
	py_entity : *Entity;
}

alloc_entity :: (using game : *Game, kind : Entity_Kind, pos : Vector2, layer : Entity_Layer, color : Vector4, rot : float) -> *Entity
{
	assert(entity_count < entity_cap);
	out : *Entity = entities + entity_count;
	out.kind = kind;
	out.pos = pos;
	out.layer = layer;
	out.color = color;
	out.rot = rot;
	entity_count += 1;
	return out;
}

update_game :: (using game : *Game, pb : *R_Push_Buffer, delta : float)
{
	if !initialized
	{
		initialized = true;
		arena = arena_init();
		entities = push_array(arena, Entity, entity_cap);
		
		yk_tex = load_tex("yk.png");
		world_tex = load_tex("bg.png");
		impolo_idle_tex = load_tex("impolo_idle.png");
		tree_tex = load_tex("tree.png");
		
		py_entity = alloc_entity(game, .Impolo, .{}, .Fg, COLOR_WHITE, 0);
		yk_entity := alloc_entity(game, .Yk, .{128, 0}, .Fg, COLOR_WHITE, 0);
		tree_entity := alloc_entity(game, .Tree, .{100, 64}, .Fg, COLOR_WHITE, 0);
		
		world_entity := alloc_entity(game, .World, .{}, .Bg, COLOR_WHITE, 0);
	}
	
	win_size := get_window_size(the_window);
	
	// update player
	{
		mv := get_input_mv();
		py_entity.pos += delta * mv * 100;
	}
	
	update_camera(*camera, win_size, delta, py_entity);
	
	proj, view := get_proj_and_view_matrix(camera);
	
	pb.proj = proj;
	pb.view = view;
	pb.viewport = win_size;
	
	// draw entities
	{
		for 0 .. entity_count - 1
		{
			e := entities + it;
			
			array_add(*entity_sort_list, e);
		}
		
		intro_sort(entity_sort_list, sort_entitties);
		
		for e : entity_sort_list
		{
			tex_size : Vector2;
			tex_id : Handle;
			if #complete e.kind == 
			{
				case .None;
				tex_id = get_white_square();
				case .Yk;
				tex_id = yk_tex;
				case .World;
				tex_id = world_tex;
				case .Impolo;
				tex_id = impolo_idle_tex;
				case .Tree;
				tex_id = tree_tex;
			}
			
			tex_size = tex_size_from_handle(tex_id);
			push_sprite(pb, e.pos, tex_size, e.rot, e.color, tex_id);
		}
		array_reset_keeping_memory(*entity_sort_list);
	}
	
	push_sprite(pb, .{-120, 0}, .{32,32}, counter * PI / 180. * 45, COLOR_MAGENTA, get_white_square());
}

sort_entitties :: (a : *Entity, b : *Entity) -> int 
{
	pos_a := a.pos;
	pos_b := b.pos;
	
	out : int = 1;
	
	if a.layer == b.layer
	{
		if pos_a.y > pos_b.y 
		{
			out = -1;
		}
	}
	else
	{
		if a.layer < b.layer
		{
			out = -1;
		}
	}
	
	return out;
}

Camera :: struct 
{
	pos : Vector3;
	zoom :: 135.;
	viewport : Vector2;
}

get_input_mv :: () -> Vector2
{
	mv : Vector2;
	if is_key_down(#char "A")
	{
		mv.x = -1;
	}
	if is_key_down(#char "D")
	{
		mv.x = 1;
	}
	if is_key_down(#char "W")
	{
		mv.y = 1;
	}
	if is_key_down(#char "S")
	{
		mv.y = -1;
	}
	return mv;
}

update_camera :: (camera : *Camera, viewport : Vector2, delta : float, target : *Entity)
{
	if !target
	{
		mv := get_input_mv();
		camera.pos.xy += delta * mv * 100;
	}
	else
	{
		camera.pos.xy = target.pos;
	}
	camera.viewport = viewport;
}

get_proj_and_view_matrix :: (camera : Camera) -> Matrix4, Matrix4
{
	aspect_ratio := (camera.viewport.x * 1.) / camera.viewport.y;
	
	proj := orthographic_projection_matrix(-aspect_ratio * camera.zoom, aspect_ratio * camera.zoom, -camera.zoom, camera.zoom, 0, 1);
	view := make_look_at_matrix(camera.pos, camera.pos + .{0, 0, -1}, .{0, 1, 0}, false);
	
	return proj, view;
}

load_tex :: (path : string, params : Tex_Params = .Nearest) -> Handle 
{
	filename := tprint("%/%", art_folder, path);
	data := read_entire_file(filename);
	
	w, h, n : s32;
	stbi_set_flip_vertically_on_load(1);
	
	bmp_data := stbi_load_from_memory(data.data, xx data.count, *w, *h, *n, 4);
	
	defer stbi_image_free(bmp_data);
	defer data;
	
	return r_image_create(w, h, n, bmp_data, params);
}