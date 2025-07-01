/*
[ ] skinned aabbs: I think the best way to deal with skinned mesh aabbs is to output vertex min / max
 after skinning

// [x] find out why some nodes are not centered
		// ohhh. I should render their mesh?
		// but what if mesh has child meshes?
		// This was happening because their origin was set to the center of the scene. They look fine after setting each mesh's origin to the center of the mesh

		// [ ] I am thinking about another asset kind that is just
		// a merged mesh. Like imagine I hash a bunch of root meshes to 
		// create a new mesh that is just the merged version of the base meshes.
		
// [ ] Use a frame arena for every system that needs per frame memory instead of using the global frame arena (a la temp memory). Use that for scratch memory maybe. For cache it should be better if you use a per - system frame arena, no?

*/

// NOTE(mizu): Global modules
#import "Basic";
#import "System";
#import "String";
#import "Math";
#import "File";
#import "File_Utilities";
#import "IntroSort";
#import "Random";
#import "stb_image";
#import "Window_Creation";
#import "Input";
#import "Windows";
#import "meow_hash";
#import "Base64";
#import "GL" (ENABLE_ALL_EXTENSIONS = true);
#import "Windows_Utf8";
#import "Unicode";
#import "freetype-2.12.1";

// NOTE(mizu): local modules
#import "jai_cgltf";

// NOTE(mizu): src code
#load "base.jai";
#load "render_opengl.jai";
#load "render.jai";
#load "camera.jai";
#load "asset.jai";
#load "game.jai";
#load "widget.jai";

the_window: Window_Type;

exe_folder : string;
data_folder : string;
models_folder : string;
shaders_folder : string;
fonts_folder : string;

main :: ()
{
	print("Do not enter is written on the doorway, why can't everyone just go away\n");
	print("Except for you, you can stay\n");
	
	SetProcessDPIAware();
	
	the_window = create_window(960, 540, "The Sad Debugger");
	
	saved : Saved_Window_Info;
	toggle_fullscreen(the_window, true, *saved);
	
	exe_folder = path_strip_filename(get_path_of_running_executable());
	
	// TODO(mizu): Make a sprint() that uses the perm arena
	data_folder = join(exe_folder, "../data");
	models_folder = join(data_folder, "/models");
	shaders_folder = join(data_folder, "/shaders");
	fonts_folder = join(data_folder, "/fonts");
	
	delta : float;
	time_elapsed : float;
	
	start := get_perf_counter();
	freq := get_perf_freq();
	
	r_init();
	asset_init();
	quit := false;
	
	game : Game;
	counter : float;
	
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
			if it.type == .MOUSE_WHEEL
			{
				wheel_delta += it.wheel_delta;
			}
		}
		
		pb := begin_render();
		update_game(*game, *pb, delta, counter);
		r_submit(pb);
		end_render(*pb);
		
		{
			dc := GetDC(the_window);
			SwapBuffers(dc);
			ReleaseDC(the_window, dc);
		}
		
		end := get_perf_counter();
		time_elapsed = (end - start) / (freq * 1.);
		delta = time_elapsed - time_since_last;
		
		reset_temporary_storage();
	}
	
	print("quit safely\n");
}

is_key_down :: inline (key : Key_Code) -> bool #must
{
	return (input_button_states[cast (s64) key] & .DOWN) != 0;
}

is_key_pressed :: inline (key : Key_Code) -> bool #must
{
	return (input_button_states[cast (s64) key] & .START) != 0;
}

wheel_delta : s32;

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