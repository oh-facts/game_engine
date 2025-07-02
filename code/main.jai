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
#load "asset.jai";
#load "widgets.jai";

Entity_Flags :: enum_flags
{
	Animated;
}

Entity :: struct
{
	// 32 chars
	// its a string view here
	short_name : string;
	short_name_memory : [32]u8;
	
	flags : Entity_Flags;
	kf_index : [256]Key_Frame_Index;
	counter : float;
	pos : Vector3;
	size : Vector3;
	rot : Vector3;
	animation_hash : u128;
	node_asset_hash : u128;
	
	// per frame artifacts
	joints : *Matrix4;
	an_batch : *Batch;
}

set_entity_name :: (e : *Entity, name : string)
{
	// names are u8
	// Will this be annoying once I have other languages?
	// Probably but its ok for now. I can't even render utf 32 text rn.
	memcpy(e.short_name_memory.data, name.data, name.count);
	e.short_name.count = name.count;
}

Font_Kind :: enum
{
	Delius;
	Akasha;
	Count;
}

/*
 Make it immediate mode!
If it can't find the glyph. It makes a call to ft to find the glyph.
Every "frame"
*/

Glyph_Key :: struct
{
	cp : u32;
	kind : Font_Kind;
	size : int;
};

Glyph :: struct
{
	next : *Glyph;
	
	advance_x : float;
	advance_y : float;
	offset_x : float;
	offset_y : float;
	ascent : float;
	descent : float;
	tex : Handle;
	height : float;
	// No need for font cache. Fixed # of fonts. ~10 fonts at best.
	// All will be preloaded at startup for now
	// So I am stuffing that stuff here.
	pt_size : int;
	font_ascent : int;
	kind : Font_Kind;
	//ft_library : FT_Library;
	
	key : Glyph_Key;
	hash : u128;
}

Glyph_Slot :: struct
{
	first : *Glyph;
	last : *Glyph;
}

Font_State :: struct
{
	arena : *Arena;
	slots : []Glyph_Slot;
	
	libraries : [Font_Kind.Count]FT_Library;
	faces: [Font_Kind.Count]FT_Face;
}

font_state : Font_State;

font_state_init :: ()
{
	using font_state;
	
	arena = arena_init();
	//frame = arena_init();
	
	slots.count = 256;
	slots.data = push_array(arena, Glyph_Slot, xx slots.count);
	
	paths :[2]string = .["delius.ttf", "akasha.ttf"];
	
	for 0 .. 1
	{
		font_path := tprint("%/%", fonts_folder, paths[it]);
		font_data := read_entire_file(font_path);
		
		FT_Init_FreeType(*libraries[it]);
		FT_New_Memory_Face(libraries[it], font_data.data, xx font_data.count, 0, *faces[it]);
	}
	
}

// documenting old stupid bug
// I can't keep strings and use as keys if I am allocating it from transient memory
// Its probably best to keep the hash around and reuse that or use the struct form of keys
// instead of data form for cases where the string is derived from the data

glyph_from_key :: (cp : u32, kind : Font_Kind, size : int) -> *Glyph
{
	using font_state;
	
	// paranoid about padding garbage creeping in
	key : Glyph_Key;
	key.cp = cp;
	key.kind = kind;
	key.size = size;
	
	out : *Glyph;
	
	data_size := size_of(type_of(key));
	
	str_key : string;
	str_key.data = tzpush_array(u8, data_size);
	str_key.count = data_size;
	memcpy(str_key.data, *key, data_size);
	//str_key := tprint("%", key);
	
	hash := hash_string(str_key);
	
	slot_idx := hash.U64[0] % cast(u64)slots.count;
	slot := *slots[slot_idx];
	
	// check if node already exists
	{
		cur := slot.first;
		while cur {
			defer cur = cur.next;
			
			if cur.hash == hash {
				out = cur;
				break;
			}
		}
	}
	
	// if not, allocate
	if !out
	{
		// allocate glyph node
		{
			out = push_struct(arena, Glyph);
			
			if !slot.first
			{
				slot.first = out;
				slot.last = out;
			}
			else
			{
				slot.last.next = out;
				slot.last = out;
			}
		}
		
		// init with key stuff
		{
			out.hash = hash;
			out.key = key;
			out.pt_size = key.size;
			out.kind = key.kind;
		}
		
		// init with freetype stuff
		{
			library := libraries[xx key.kind];
			face := faces[xx key.kind];
			
			FT_Set_Char_Size(face, 0, xx (key.size * 64), 0, 96);
			
			out.ascent = xx face.ascender >> 6;
			out.descent = xx face.descender >> 6;
			
			ch, count, _ := character_utf8_to_utf32(xx *key.cp, 1);
			
			index := FT_Get_Char_Index(face, ch);
			
			FT_Load_Glyph(face, index, FT_LOAD_DEFAULT | FT_LOAD_RENDER);
			
			{
				out.advance_x = xx face.glyph.advance.x >> 6;
				out.advance_y = xx face.glyph.advance.y >> 6;
				out.offset_x = xx face.glyph.bitmap_left;
				out.offset_y = xx face.glyph.bitmap_top;
				out.height = xx face.size.metrics.height >> 6;
			}
			
			width := face.glyph.bitmap.width;
			height := face.glyph.bitmap.rows;
			bytes := face.glyph.bitmap.buffer;
			
			in_size := width * height;
			out_size := width * height * 4;
			
			buffer :*u8= xx tzpush_array(u8, out_size);
			
			i := 0;
			j := 0;
			
			while i != in_size
			{
				a := (cast(*u8)bytes)[i];
				
				if a
				{
					ew : int;
				}
				
				buffer[j + 0] = 255;
				buffer[j + 1] = 255;
				buffer[j + 2] = 255;
				buffer[j + 3] = a;
				
				i += 1;
				j += 4;
			}
			
			out.tex = r_image_create(xx width, xx height, 4, buffer, .Linear, .Linear, .Clamp_To_Edge);
		}
	}
	
	return out;
	//print("% %\n", hash, i);
}

//cps :: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ{}";

Entity_State :: struct
{
	arena : *Arena;
	entities : []Entity;
}

entity_state_init :: () -> Entity_State
{
	out : Entity_State;
	using out;
	
	arena = arena_init();
	entities.data = push_array(arena, Entity, 100);
	
	return out;
}

entity_alloc :: (using entity_state : *Entity_State) -> *Entity
{
	out := entities.data + entities.count;
	out.size = .{1,1,1};
	out.short_name.data = out.short_name_memory.data;
	entities.count += 1;
	return out;
}

Camera :: struct
{
	speed := 4.0;
	ROTATION_SPEED :: 0.3;
	ROTATION_SMOOTHING :: 0.3;
	
	position : Vector3;
	euler_angles : Vector3;
	rotation : Quaternion;
	rotation_input : Vector2;
	fov := 60.0;
	transform := Matrix4_Identity;
	
	viewport : Vector2;
	
	control : bool;
}

update_2d_camera :: (using camera : *Camera, delta : float, _viewport : Vector2)
{
	viewport = _viewport;
}

update_flying_camera :: (using camera : *Camera, delta_time : float, vp : Vector2)
{
	viewport = vp;
	
	mouse_delta : Vector2;
	move_input  : Vector3;
	move_speed  : float;
	
	if control 
	{
		x, y, w, h := get_dimensions (the_window, false);
		user32 :: #system_library "User32";
		SetCursorPos :: (x : s32, y : s32) -> s32 #foreign user32;
		SetCursorPos (w / 2, h / 2);
	}
	
	if control 
	{
		move_speed = speed;
		mouse_delta = xy (xx mouse_delta_x, xx mouse_delta_y);
		if is_key_down (.SHIFT) then move_speed *= 10;
		move_speed *= delta_time;
		move_input.x = cast (float) is_key_down (xx #char "D")
			- cast (float) is_key_down (xx #char "A");
		move_input.y = cast (float) is_key_down (xx #char "E")
			- cast (float) is_key_down (xx #char "Q");
		move_input.z = cast (float) is_key_down (xx #char "S")
			- cast (float) is_key_down (xx #char "W");
		move_input = rotate (unit_vector (move_input), rotation);
	}
	position += move_input * move_speed;
	
	//position.y = 0.15;
	
	rotation_input = lerp (rotation_input, mouse_delta, ROTATION_SMOOTHING);
	delta := rotation_input * ROTATION_SPEED;
	euler_angles.x += delta.x * PI / 180.0;
	euler_angles.y += delta.y * PI / 180.0;
	euler_angles.y = clamp (euler_angles.y, -80.0  * PI / 180.0, 80.0 * PI / 180.0);
	yaw : Quaternion;
	// I am not sure why I need to invert the axis of rotation...
	// nor am I jon (or whoever else at thekla who on this)
	set_from_axis_and_angle (*yaw, 0, -1, 0, euler_angles.x);
	pitch : Quaternion;
	set_from_axis_and_angle (*pitch, -1, 0, 0, euler_angles.y);
	rotation = yaw * pitch;
	
	transform = make_translation_matrix4 (position) * rotation_matrix (Matrix4, rotation);
}

get_ortho_proj_and_view_matrix :: (camera : Camera) -> Matrix4, Matrix4
{
	aspect_ratio := (camera.viewport.x * 1.) / camera.viewport.y;
	
	proj := orthographic_projection_matrix(0, camera.viewport.x, camera.viewport.y, 0, 0, 1);
	view := make_look_at_matrix(camera.position, camera.position + .{0, 0, -1}, .{0, 1, 0}, false);
	
	return proj, view;
}

get_perspective_proj_and_view_matrix :: (using camera : Camera) -> Matrix4, Matrix4
{
	view_matrix := inverse (transform);
	
	aspect_ratio := viewport.x / cast (float) viewport.y;
	projection_matrix := make_projection_matrix (fov * PI / 180.0, aspect_ratio, 0.1, 1000.0);
	
	return projection_matrix, view_matrix;
}

hot_entity : *Entity;
active_entity : *Entity;
is_grabbing : bool;
grab_index : int = -1;
raycast_last_frame : Ray;
raycast : Ray;
current_gizmo_mode : Gizmo_Mode;

Gizmo_Mode :: enum
{
	Translate;
	Scale;
	Rotate;
}

active_node_asset_hash : u128;
active_mesh_asset_hash : u128;

main :: ()
{
	print("Do not enter is written on the doorway, why can't everyone just go away\n");
	print("Except for you, you can stay\n");
	
	SetProcessDPIAware();
	
	the_window = create_window(960, 540, "The Sad Debugger");
	
	saved : Saved_Window_Info;
	//toggle_fullscreen(the_window, true, *saved);
	
	exe_folder = path_strip_filename(get_path_of_running_executable());
	
	// TODO(mizu): Make a sprint() that uses the perm arena
	data_folder = join(exe_folder, "../data");
	models_folder = join(data_folder, "/models");
	shaders_folder = join(data_folder, "/shaders");
	fonts_folder = join(data_folder, "/fonts");
	
	boss_window := init_editor_window("asset viewer", .{32, 32}, .{300, 300});
	
	delta : float;
	time_elapsed : float;
	
	start := get_perf_counter();
	freq := get_perf_freq();
	
	r_init();
	asset_init();	
	font_state_init();
	widget_init();
	
	quit := false;
	
	arena : *Arena;
	
	ui_camera : Camera;
	
	arena = arena_init();
	
	// Make the gltf load file thing part of the node_from_key
	// then when you do cow.walk.
	// it loads cow.glb
	// and extracts walk and whatever else
	
	gltf_load_file(arena, "watermelon_stall.glb");
	gltf_load_file(arena, "cow.glb");
	
	//control_camera = true;
	//toggle_cursor(0);
	
	entity_state := entity_state_init();
	
	{
		po := entity_alloc(*entity_state);
		po.node_asset_hash = hash_string("watermelon_stall.root");
		set_entity_name(po, "wa'er melon s'all");
	}
	
	{
		po := entity_alloc(*entity_state);
		po.node_asset_hash = hash_string("cow.cow_root");
		set_entity_name(po, "moo machine");
	}
	
	//watermelon_stall.root
	
	jeff : int;
	
	counter : float;
	
	while !quit
	{
		counter += delta;
		
		time_since_last := time_elapsed;
		wheel_delta = 0;
		
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
		win_size := get_window_size(the_window);
		
		x,y := get_mouse_pointer_position(the_window, false);
		
		update_2d_camera(*ui_camera, delta, win_size);
		
		ui_proj, ui_view := get_ortho_proj_and_view_matrix(ui_camera);
		
		pb.viewport = rectF32(0, 0, win_size.x, win_size.y);
		
		scissor := rectF32(0, 0, win_size.x, win_size.y);
		{
			params := push_batch_group_sprite_params(*pb);
			params.proj = ui_proj;
			params.view = ui_view;
			params.scissor = scissor;
		}
		
		begin_widgets(.{xx x,xx y});
		begin_editor_window(*boss_window);
		boss_window.counter += delta;
		
		// update tabs
		{
			current_editor_tab := *boss_window.tabs[boss_window.current_app_mode_tab];
			
			update_flying_camera(*current_editor_tab.camera, delta, win_size);
			proj, view := get_perspective_proj_and_view_matrix(current_editor_tab.camera);
			pb.proj = proj;
			pb.view = view;
			
			if is_key_pressed(.TAB)
			{
				toggle_cursor(xx current_editor_tab.camera.control);
				current_editor_tab.camera.control = !current_editor_tab.camera.control;
			}
			
			if !boss_window.hide
			{
				// idk if contexts are expensive like that
				new_context := context;
				push_context new_context
				{
					format_float := *context.print_style.default_format_float;
					format_float.trailing_width = 1;
					
					simple_label(tprint("%, %, %", current_editor_tab.camera.position.x, current_editor_tab.camera.position.y, current_editor_tab.camera.position.z), .{180, 20});
					
					rot := deg_rot_from_rad_rot(current_editor_tab.camera.euler_angles);
					
					simple_label(tprint("%, %, %", rot.x, rot.y, rot.z), .{180, 20});
				}
				
				if boss_window.current_app_mode_tab ==
				{
					case .Asset_Viewer;
					node_view_key := make_widget_key();
					node_view := widget_from_key(node_view_key);
					
					mesh_view_key := make_widget_key();
					mesh_view := widget_from_key(mesh_view_key);
					
					simple_spacer_widget(0,2);
					
					node_view.text = "nodes"; 
					node_view.size = .{55, 20};
					node_view.flags |= .Draw_Text | .Draw_Bg;
					node_view.font_size = 12;
					
					mesh_view.text = "meshes"; 
					mesh_view.size = .{65, 20};
					mesh_view.flags |= .Draw_Text | .Draw_Bg;
					mesh_view.font_size = 12;
					
					if current_asset_viewer_tab == .Node
					{
						node_view.active = true;
					}
					
					else if current_asset_viewer_tab == .Mesh
					{
						mesh_view.active = true;
					}
					
					if signal_from_widget(node_view)
					{
						current_asset_viewer_tab = .Node;
					}
					
					else if signal_from_widget(mesh_view)
					{
						current_asset_viewer_tab = .Mesh;
					}
					
					col();
					placer_widget_root := _start;
					
					if point_in_rect(.{xx last_mpos_x, xx last_mpos_y}, rectF32(placer_widget_root.final_pos, placer_widget_root.final_size))
					{
						boss_window.scroll_offsets[current_asset_viewer_tab] += wheel_delta;
					}
					
					placer_widget_root.view_offset.y = boss_window.scroll_offsets[current_asset_viewer_tab];
					placer_widget_root.clip_size = boss_window.size;
					placer_widget_root.flags |= .Clip;
					
					asset_index : int;
					
					if current_asset_viewer_tab == 
					{
						case .Mesh;
						
						for slot : asset_store.meshes
						{
							asset := slot.first;
							while asset
							{
								active, widg := fixed_label(tprint("%", asset.key), asset_index);
								
								if active_mesh_asset_hash == asset.hash
								{
									widg.active = true;
								}
								
								if active
								{
									active_mesh_asset_hash = asset.hash;
								}
								asset_index += 1;
								asset = asset.hash_next;
							}
						}
						
						if active_mesh_asset_hash.U64[0]
						{
							yaw : Quaternion;
							set_from_axis_and_angle (*yaw, 0, -1, 0, boss_window.counter);
							model := rotation_matrix(Matrix4, yaw);
							
							if boss_window.draw_asset
							{
								push_mesh(*pb, model, active_mesh_asset_hash);
							}
							
							if boss_window.draw_aabb
							{
								draw_mesh_aabb(*pb, active_mesh_asset_hash, model);
							}
						}
						
						case .Node;
						for slot : asset_store.nodes
						{
							asset := slot.first;
							while asset
							{
								if !asset.parent_key.count
								{
									active, widg := fixed_label(tprint("%", asset.key), asset_index);
									
									if active_node_asset_hash == asset.hash
									{
										widg.active = true;
									}
									
									if active
									{
										active_node_asset_hash = asset.hash;
									}
								}
								asset_index += 1;
								asset = asset.hash_next;
							}
						}
						
						if active_node_asset_hash.U64[0]
						{
							yaw : Quaternion;
							set_from_axis_and_angle (*yaw, 0, -1, 0, boss_window.counter);
							model := rotation_matrix(Matrix4, yaw);
							
							if boss_window.draw_asset
							{
								push_mesh_node(*pb, model, active_node_asset_hash);
							}
							
							if boss_window.draw_aabb
							{
								draw_node_asset_aabb(*pb, active_node_asset_hash, model);
							}
						}
					}
					
					case .Game;
					
					simple_label(tprint("%", current_gizmo_mode), .{100,20});
					
					// idk if contexts are expensive like that
					new_context := context;
					push_context new_context
					{
						format_float := *context.print_style.default_format_float;
						format_float.trailing_width = 1;
						
						for e : entity_state.entities
						{
							simple_label(e.short_name, .{300, 20}, it_index);
							
							{
								row(it_index);
								simple_spacer_widget(20, 0, it_index);
								{
									col(it_index);
									simple_label(tprint("pos:  %, %, %", e.pos.x, e.pos.y, e.pos.z), .{280, 20}, it_index);
									
									rot := deg_rot_from_rad_rot(e.rot);
									
									simple_label(tprint("rot:  %, %, %", rot.x, rot.y, rot.z), .{280, 20}, it_index);
									simple_label(tprint("size: %, %, %", e.size.x, e.size.y, e.size.z), .{280, 20}, it_index);
								}
							}
						}
					}
					
					{
						ray_nds : Vector2;
						ray_nds.x = (x / win_size.x) * 2 - 1;
						ray_nds.y = - ((y / win_size.y) * 2 - 1);
						
						//print("%\n", ray_nds);
						
						ray_clip : Vector4;
						ray_clip.xy = ray_nds;
						ray_clip.z = -1;
						ray_clip.w = 1;
						
						ray_eye := inverse(proj) * ray_clip;
						ray_eye.z = -1;
						ray_eye.w = 0;
						
						ray_wor : Vector3 = (inverse(view) * ray_eye).xyz;
						ray_wor = normalize(ray_wor);
						
						start := current_editor_tab.camera.position;
						//end := start + 1000 * ray_wor;
						
						raycast_last_frame = raycast;
						raycast = .{start, ray_wor};
					}
					
					if active_entity
					{
						gizmo_size : Vector2 = .{0.5, 2};
						gizmo_delta := (gizmo_size.x + gizmo_size.y) / 2.;
						
						for 0 .. 2
						{
							axis : Vector3;
							axis.component[it] = gizmo_delta;
							gizmo_pos := active_entity.pos + axis;
							gizmo_color : Vector4;
							gizmo_color.w = 1;
							gizmo_color.component[it] = 1;
							
							gizmo_rot : Vector3;
							if it == 0 gizmo_rot.z = deg_to_rad(90);
							else if it == 2 gizmo_rot.x = deg_to_rad(90);
							
							push_quad(*pb, gizmo_pos, gizmo_size, gizmo_rot, gizmo_color, get_white_square());
						}
					}
					
					if active_entity && !current_editor_tab.camera.control
					{
						gizmo_size : Vector2 = .{0.5, 2};
						gizmo_delta := (gizmo_size.x + gizmo_size.y) / 2.;
						
						if is_grabbing && !is_key_down(.MOUSE_BUTTON_LEFT)
						{
							is_grabbing = false;
						}
						
						if is_key_pressed(#char "D")
						{
							active_entity.size = .{1,1,1};
						}
						
						if is_key_pressed(#char "S")
						{
							current_gizmo_mode = .Scale;
						}
						
						else if is_key_pressed(#char "T")
						{
							current_gizmo_mode = .Translate;
						}
						
						else if is_key_pressed(#char "R")
						{
							current_gizmo_mode = .Rotate;
						}
						
						for 0 .. 2
						{
							axis : Vector3;
							axis.component[it] = gizmo_delta;
							gizmo_pos := active_entity.pos + axis;
							gizmo_color : Vector4;
							gizmo_color.w = 1;
							gizmo_color.component[it] = 1;
							
							gizmo_rot : Vector3;
							if it == 0 gizmo_rot.z = deg_to_rad(90);
							else if it == 2 gizmo_rot.x = deg_to_rad(90);
							
							//push_quad(*pb, gizmo_pos, gizmo_size, gizmo_rot, gizmo_color, get_white_square());
							
							half_extents : Vector3;
							
							// probably a math way to generalize this
							if it == 0
							{
								half_extents = .{gizmo_size.y / 2, gizmo_size.x / 2, 0};
							}
							else if it == 1
							{
								half_extents = .{gizmo_size.x / 2, gizmo_size.y / 2, 0};
							}
							else if it == 2
							{
								half_extents = .{gizmo_size.x / 2, 0, gizmo_size.y / 2};
							}
							
							aabb : AABB;
							aabb.min = gizmo_pos - half_extents;
							aabb.max = gizmo_pos + half_extents;
							
							t, hit := ray_aabb_intersection(raycast, aabb);
							
							if hit && is_key_down(.MOUSE_BUTTON_LEFT) && !is_grabbing
							{
								is_grabbing = true;
								grab_index = it;
							}
							
							if is_grabbing && it == grab_index
							{
								t : float;
								tt : float;
								if it == 0
								{
									t = ray_plane_intersection(raycast, .{gizmo_pos.z, .{0, 0, 1}, true});
									tt = ray_plane_intersection(raycast_last_frame, .{gizmo_pos.z, .{0, 0, 1}, true});
								}
								else if it == 1
								{
									t = ray_plane_intersection(raycast, .{gizmo_pos.z, .{0, 0, 1}, true});
									tt = ray_plane_intersection(raycast_last_frame, .{gizmo_pos.z, .{0, 0, 1}, true});
								}
								else if it == 2
								{
									t = ray_plane_intersection(raycast, .{gizmo_pos.y, .{0, 1, 0}, true});
									tt = ray_plane_intersection(raycast_last_frame, .{gizmo_pos.y, .{0, 1, 0}, true});
								}
								
								hit_pos := raycast.o + raycast.dir * t;
								hit_pos_last := raycast_last_frame.o + raycast_last_frame.dir * tt;
								
								movement := dot(hit_pos - hit_pos_last, axis);
								
								if current_gizmo_mode ==
								{
									case .Translate;
									active_entity.pos += axis * movement * delta * 100;
									case .Scale;
									active_entity.size += axis * movement * delta * 100;
									case .Rotate;
									active_entity.rot += axis * movement * delta * 100;
								}
								
								//active_entity.pos.component[it] += hit_pos.component[it] - hit_pos_last.component[it];
							}
						}
						
						if is_key_down(xx #char "C")
						{
							active_entity = null;
						}
					}
					
					// animate entities
					for *e : entity_state.entities
					{
						if e.flags & .Animated
						{
							anim, jaunt, asset := animation_data_from_hash(e.animation_hash);
							
							if e.counter > asset.length
							{
								for i : 0 .. 255
								{
									e.kf_index[i].pos = 0;
									e.kf_index[i].rot = 0;
									e.counter = 0;
								}
							}
							
							e.counter += delta;
							
							joints, an_batch := push_animation(*pb, e.animation_hash, e.counter, e.kf_index);
							e.joints = joints;
							e.an_batch = an_batch;
						}
					}
					
					// draw entities
					for e : entity_state.entities
					{
						color := COLOR_WHITE;
						if 0
						{
							if *e == hot_entity
							{
								color = COLOR_YELLOW;
							}
							if *e == active_entity
							{
								color = COLOR_BLUE;
							}
						}
						
						model := translate(Matrix4_Identity, e.pos);
						
						roll : Quaternion;
						set_from_axis_and_angle (*roll, 0, 0, -1, e.rot.z);
						pitch : Quaternion;
						set_from_axis_and_angle (*pitch, -1, 0, 0, e.rot.x);
						yaw : Quaternion;
						set_from_axis_and_angle (*yaw, 0, -1, 0, e.rot.y);
						rotation := roll * yaw * pitch;
						
						model = rotate(model, rotation);
						model = scale(model, e.size);
						
						push_mesh_node(*pb, model, e.node_asset_hash, color, e.joints, e.an_batch);
					}
					
					aabb_rec :: (e : *Entity, pb : *R_Push_Buffer, hash : u128, _model : Matrix4, this_frame_hot : *bool)
					{
						node := node_from_hash(hash);
						model := _model * node.xform;
						
						if node.mesh.count
						{
							m := mesh_from_hash(node.mesh_hash);
							
							using m.aabb;
							
							aabb : AABB;
							aabb.min = (model * .{m.aabb.min.x, m.aabb.min.y, m.aabb.min.z, 1}).xyz;
							aabb.max = (model * .{m.aabb.max.x, m.aabb.max.y, m.aabb.max.z, 1}).xyz;
							
							_, hit := ray_aabb_intersection(raycast, aabb);
							
							color := COLOR_WHITE;
							
							if hit
							{
								color = COLOR_RED;
								hot_entity = e;
								this_frame_hot.* = true;
								
								if is_key_pressed(.MOUSE_BUTTON_LEFT) && !is_grabbing
								{
									active_entity = e;
								}
							}
							
							/*
							points : [8]Vector3;
					
							xs : [2]float = .[min.x, max.x];
							ys : [2]float = .[min.y, max.y];
							zs : [2]float = .[min.z, max.z];
					
							for x : 0 .. 1
							{
								for y : 0 .. 1
								{
									for z : 0 .. 1
									{
										point := model * m.xform * .{xs[x], ys[y], zs[z], 1};
					
										points[x * 2 * 2 + y * 2 + z] = point.xyz;
										push_debug_vertex(pb, point.xyz, COLOR_RED);
									}
								}
							}
							*/
							
							/*
							// NOTE(prismo):
							a=['min.x', 'max.x']
							a1=['min.y', 'max.y']
							a2=['min.z', 'max.z']
							l=[]
							for i in a:
								for j in a1:
										for k in a2:
												l1=[i,j,k]
												l.append(l1)
							r=[]
							for i in l:
								for j in l:
										if [j,i] not in r:
												if i[1]==j[1] and i[2]==j[2] and i!=j:
														k=[i,j]
														r.append(k)
												elif i[0]==j[0] and i[2]==j[2] and i!=j:
														k=[i,j]
														r.append(k)
												elif i[0]==j[0] and i[1]==j[1] and i!=j:
														k=[i,j]
														r.append(k)
							count=0
							for i in r:
								count+=1
								#print(count)
								print(i)
							*/
							
							edges : [12][2]Vector3;
							
							edges[0] = .[.{min.x, min.y, min.z}, .{min.x, min.y, max.z}];
							edges[1] = .[.{min.x, min.y, min.z}, .{min.x, max.y, min.z}];
							edges[2] = .[.{min.x, min.y, min.z}, .{max.x, min.y, min.z}];
							edges[3] = .[.{min.x, min.y, max.z}, .{min.x, max.y, max.z}];
							edges[4] = .[.{min.x, min.y, max.z}, .{max.x, min.y, max.z}];
							edges[5] = .[.{min.x, max.y, min.z}, .{min.x, max.y, max.z}];
							edges[6] = .[.{min.x, max.y, min.z}, .{max.x, max.y, min.z}];
							edges[7] = .[.{min.x, max.y, max.z}, .{max.x, max.y, max.z}];
							edges[8] = .[.{max.x, min.y, min.z}, .{max.x, min.y, max.z}];
							edges[9] = .[.{max.x, min.y, min.z}, .{max.x, max.y, min.z}];
							edges[10] = .[.{max.x, min.y, max.z}, .{max.x, max.y, max.z}];
							edges[11] = .[.{max.x, max.y, min.z}, .{max.x, max.y, max.z}];
							
							// local space -> world space and drawing
							for edge : edges
							{
								for *edge
								{
									<< it = (model * .{it.x, it.y, it.z, 1}).xyz;
								}
								push_debug_line(pb, edge[0], edge[1], color);
							}
						}
						
						if !this_frame_hot
						{
							hot_entity = null;
						}
						
						child_asset_node : *Asset;
						
						if node.first_key.count
						{
							child_asset_node = node_from_hash(node.first_hash);
						}
						
						while child_asset_node
						{
							aabb_rec(e, pb, child_asset_node.hash, model, this_frame_hot);
							
							if child_asset_node.next_key.count
							{
								child_asset_node = node_from_hash(child_asset_node.next_hash);
							}
							else
							{
								break;
							}
						}
					}
					
					// draw aabbs
					if boss_window.draw_aabb
					{
						for *e : entity_state.entities
						{
							model := translate(Matrix4_Identity, e.pos);
							model = scale(model, e.size);
							
							this_frame_hot : bool;
							
							aabb_rec(e, *pb, e.node_asset_hash, model, *this_frame_hot);
						}
					}
					
				}
			}
			
			
		}
		
		end_editor_window(*pb, *boss_window);
		end_widgets();
		
		pop_batch_group_sprite_params(*pb);
		r_submit(pb);
		end_render(*pb);
		
		swap_buffers(the_window);
		
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

swap_buffers :: (win : Window_Type)
{
	dc := GetDC(the_window);
	SwapBuffers(dc);
	ReleaseDC(the_window, dc);
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

the_window: Window_Type;

exe_folder : string;
data_folder : string;
models_folder : string;
shaders_folder : string;
fonts_folder : string;

Editor_Tab :: struct
{
	camera : Camera;
}

Editor_Window :: struct
{
	title : string;
	pos : Vector2;
	size : Vector2;
	mouse_last_pos : Vector2;
	is_dragging : bool;
	hide : bool;
	widget_root : *Widget;
	counter : f32;
	
	scroll_offsets : [2]float;
	
	hacker_draw : bool;
	draw_asset : bool;
	draw_aabb : bool;
	
	current_app_mode_tab : App_Mode_Tab;
	tabs : [2]Editor_Tab;
}

init_editor_window :: (title : string, pos : Vector2, size : Vector2) -> Editor_Window
{
	out : Editor_Window;
	out.title = title;
	out.pos = pos;
	out.size = size;
	out.draw_asset = true;
	out.current_app_mode_tab = .Game;
	
	// nice angle
	out.tabs[App_Mode_Tab.Asset_Viewer].camera.position = .{-2, 6.4, 8.6};
	out.tabs[App_Mode_Tab.Asset_Viewer].camera.euler_angles = .{deg_to_rad(15), deg_to_rad(32), 0};
	
	// copied the above one
	out.tabs[App_Mode_Tab.Game].camera.position = .{-2, 6.4, 8.6};
	out.tabs[App_Mode_Tab.Game].camera.euler_angles = .{deg_to_rad(15), deg_to_rad(32), 0};
	
	return out;
}

begin_editor_window :: (window : *Editor_Window)
{
	using widget_state;
	
	root := begin_col();
	root.fixed_pos = window.pos;
	
	bar_key := make_widget_key();
	bar := widget_from_key(bar_key);
	
	begin_parent(bar);
	bar.child_axis = .X;
	
	hide_key := make_widget_key();
	hide := widget_from_key(hide_key);
	
	tabs_key := make_widget_key();
	tab := widget_from_key(tabs_key);
	begin_parent(tab);
	tab.child_axis = .X;
	
	asset_tab_key := make_widget_key();
	asset_tab := widget_from_key(asset_tab_key);
	
	game_tab_key := make_widget_key();
	game_tab := widget_from_key(game_tab_key);
	
	end_parent();
	end_parent();
	
	// styling
	asset_tab.text = "asset";
	asset_tab.size = .{140, 20};
	asset_tab.flags |= .Draw_Text | .Draw_Bg;
	asset_tab.font_size = 12;
	
	game_tab.text = "game";
	game_tab.size = .{140, 20};
	game_tab.flags |= .Draw_Text | .Draw_Bg;
	game_tab.font_size = 12;
	
	hide.text = ifx !window.hide then "v" else ">"; 
	hide.size = .{20, 20};
	hide.flags |= .Draw_Text | .Draw_Bg;
	hide.font_size = 12;
	
	// interactions
	if signal_from_widget(tab) 
	{
		window.is_dragging = true;
	}
	
	else if signal_from_widget(hide)
	{
		window.hide = !window.hide;
	}
	
	if signal_from_widget(asset_tab) 
	{
		window.current_app_mode_tab = .Asset_Viewer;
	}
	
	else if signal_from_widget(game_tab) 
	{
		window.current_app_mode_tab = .Game;
	}
	
	if window.current_app_mode_tab == .Asset_Viewer
	{
		asset_tab.active = true;
	}
	
	else if window.current_app_mode_tab == .Game
	{
		game_tab.active = true;
	}
	
	window.widget_root = root;
	
	x,y := get_mouse_pointer_position(the_window, false);
	
	if window.is_dragging
	{
		delta := Vector2.{xx x, xx y} - Vector2.{xx last_mpos_x, xx last_mpos_y};
		window.pos += delta;
		
		if !is_key_down(.MOUSE_BUTTON_LEFT)
		{
			window.is_dragging = false;
		}
	}
	
	last_mpos_x, last_mpos_y = get_mouse_pointer_position(the_window, false);
	
	{
		r_flag := widget_from_key(make_widget_key());
		
		// text alignment is a bikeshed feature
		r_flag.text = "       please enjoy each flag equally";
		r_flag.size = .{300, 20};
		r_flag.flags |= .Draw_Text | .Draw_Bg;
		r_flag.font_size = 12;
	}
	
	simple_spacer_widget(0,2);
	
	{
		// pls enjoy each flag equally
		row();
		simple_radio_widget(*window.hacker_draw);
		simple_spacer_widget(20,20);
		simple_radio_widget(*window.draw_asset);
		simple_spacer_widget(20,20);
		simple_radio_widget(*window.draw_aabb);
		simple_spacer_widget(20,20);
		simple_radio_widget(*window.hide);
	}
	
	simple_spacer_widget(0,2);
}

end_editor_window :: (pb : *R_Push_Buffer, window : *Editor_Window)
{
	end_col();
	pb.hacker_draw = window.hacker_draw;
	window.widget_root.parent = *nil_widget;
	layout_and_clip_widgets(window.widget_root);
	draw_widgets(pb, window.widget_root);
}

nil_widget : Widget;
draw_node_asset_aabb :: (pb : *R_Push_Buffer, hash : u128, _model : Matrix4)
{
	node := node_from_hash(hash);
	model := _model * node.xform;
	
	if node.mesh.count
	{
		draw_mesh_aabb(pb, node.mesh_hash, model);
	}
	
	child_asset_node : *Asset;
	
	if node.first_key.count
	{
		child_asset_node = node_from_hash(node.first_hash);
	}
	
	while child_asset_node
	{
		draw_node_asset_aabb(pb, child_asset_node.hash, model);
		
		if child_asset_node.next_key.count
		{
			child_asset_node = node_from_hash(child_asset_node.next_hash);
		}
		else
		{
			break;
		}
	}
}

draw_mesh_aabb :: (pb : *R_Push_Buffer, hash : u128, model : Matrix4)
{
	m := mesh_from_hash(hash);
	
	using m.aabb;
	
	edges : [12][2]Vector3;
	
	edges[0] = .[.{min.x, min.y, min.z}, .{min.x, min.y, max.z}];
	edges[1] = .[.{min.x, min.y, min.z}, .{min.x, max.y, min.z}];
	edges[2] = .[.{min.x, min.y, min.z}, .{max.x, min.y, min.z}];
	edges[3] = .[.{min.x, min.y, max.z}, .{min.x, max.y, max.z}];
	edges[4] = .[.{min.x, min.y, max.z}, .{max.x, min.y, max.z}];
	edges[5] = .[.{min.x, max.y, min.z}, .{min.x, max.y, max.z}];
	edges[6] = .[.{min.x, max.y, min.z}, .{max.x, max.y, min.z}];
	edges[7] = .[.{min.x, max.y, max.z}, .{max.x, max.y, max.z}];
	edges[8] = .[.{max.x, min.y, min.z}, .{max.x, min.y, max.z}];
	edges[9] = .[.{max.x, min.y, min.z}, .{max.x, max.y, min.z}];
	edges[10] = .[.{max.x, min.y, max.z}, .{max.x, max.y, max.z}];
	edges[11] = .[.{max.x, max.y, min.z}, .{max.x, max.y, max.z}];
	
	// local space -> world space and drawing
	for edge : edges
	{
		for *edge
		{
			<< it = (model * .{it.x, it.y, it.z, 1}).xyz;
		}
		push_debug_line(pb, edge[0], edge[1], COLOR_WHITE);
	}
}

last_mpos_x, last_mpos_y : int;

current_asset_viewer_tab : Asset_Viewer_Tab;

Asset_Viewer_Tab :: enum
{
	Node;
	Mesh;
}

App_Mode_Tab :: enum
{
	Asset_Viewer;
	Game;
}

deg_rot_from_rad_rot :: (rad : Vector3) -> Vector3i
{
	rot : Vector3i;
	rot.x = cast(s32) ((xx rad_to_deg(rad.x)) % 360 + 360) % 360;
	rot.y = cast(s32) ((xx rad_to_deg(rad.y)) % 360 + 360) % 360;
	rot.z = cast(s32) ((xx rad_to_deg(rad.z)) % 360 + 360) % 360;
	
	return rot;
}

// For when you return, you were going to make the entity updating thing its own thing.
// Maybe make a tab for it. Maybe put the asset viewing thing in a tab function.
// call begin and end window like normal, but process whatever tab is selected


/*
entity_widget_root := *nil_widget;
	new_context := context;
	push_context new_context
	{
		
		if false
		{
			col();
			entity_widget_root = _start;
			
			format_float := *context.print_style.default_format_float;
			format_float.trailing_width = 1;
			
			if active_entity
			{
				txt := tprint("pos: % % %", active_entity.pos.x, active_entity.pos.y, active_entity.pos.z);
				fixed_label(txt);
				
				rot : Vector3i;
				rot.x = xx rad_to_deg(active_entity.rot.x);
				rot.y = xx rad_to_deg(active_entity.rot.y);
				rot.z = xx rad_to_deg(active_entity.rot.z);
				
				rot.x %= 360;
				rot.y %= 360;
				rot.z %= 360;
				
				txt = tprint("rot: % % %", rot.x, rot.y, rot.z);
				fixed_label(txt);
				
				txt = tprint("size: % % %", active_entity.size.x, active_entity.size.y, active_entity.size.z);
				fixed_label(txt);
			}
		}
	}
	
*/