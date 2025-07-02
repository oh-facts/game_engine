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
#load "editor.jai";

Entity_Flags :: enum_flags
{
	Animated;
}

Entity :: struct
{
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
	
	key : string;
}

Glyph_Slot :: struct
{
	first : *Glyph;
	last : *Glyph;
}

Font_State :: struct
{
	arena : *Arena;
	frame : *Arena;
	slots : []Glyph_Slot;
	
	libraries : [Font_Kind.Count]FT_Library;
	faces: [Font_Kind.Count]FT_Face;
}

font_state : Font_State;

font_begin :: ()
{
	using font_state;
	frame.used = ARENA_HEADER_SIZE;
}

font_state_init :: ()
{
	using font_state;
	
	arena = arena_init();
	frame = arena_init();
	
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

glyph_from_key :: (key : Glyph_Key) -> *Glyph
{
	using font_state;
	
	out : *Glyph;
	
	data_size := size_of(type_of(key));
	
	str_key : string;
	str_key.data = push_array(frame, u8, xx data_size);
	str_key.count = data_size;
	memcpy(str_key.data, *key, data_size);
	
	hash := hash_string(str_key);
	
	slot_idx := hash.U64[0] % cast(u64)slots.count;
	slot := *slots[slot_idx];
	
	// check if node already exists
	{
		cur := slot.first;
		while cur {
			defer cur = cur.next;
			
			if cur.key == str_key {
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
			out.key = str_key;
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
	
	if control_camera 
	{
		x, y, w, h := get_dimensions (the_window, false);
		user32 :: #system_library "User32";
		SetCursorPos :: (x : s32, y : s32) -> s32 #foreign user32;
		SetCursorPos (w / 2, h / 2);
	}
	
	if control_camera 
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
current_app_mode : App_Mode;

Gizmo_Mode :: enum
{
	Translate;
	Scale;
	Rotate;
}

App_Mode :: enum
{
	Game;
	Editor;
	Count;
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
	toggle_fullscreen(the_window, true, *saved);
	
	exe_folder = path_strip_filename(get_path_of_running_executable());
	
	// TODO(mizu): Make a sprint() that uses the perm arena
	data_folder = join(exe_folder, "../data");
	models_folder = join(data_folder, "/models");
	shaders_folder = join(data_folder, "/shaders");
	fonts_folder = join(data_folder, "/fonts");
	
	asset_viewer_window := init_editor_window("asset viewer", .{600, 300}, .{300, 300});
	
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
	
	camera : Camera;
	ui_camera : Camera;
	
	arena = arena_init();
	
	// Make the gltf load file thing part of the node_from_key
	// then when you do cow.walk.
	// it loads cow.glb
	// and extracts walk and whatever else
	
	gltf_load_file(arena, "watermelon_stall.glb");
	gltf_load_file(arena, "cow.glb");
	
	camera.position = .{0, 0, 3};
	control_camera = true;
	toggle_cursor(0);
	
	entity_state := entity_state_init();
	
	//po := entity_alloc(*entity_state);
	//po.node_asset_hash = hash_string("watermelon_stall.root");
	
	//watermelon_stall.root
	
	jeff : int;
	
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
		win_size := get_window_size(the_window);
		
		update_flying_camera(*camera, delta, win_size);
		update_2d_camera(*ui_camera, delta, win_size);
		proj, view := get_perspective_proj_and_view_matrix(camera);
		ui_proj, ui_view := get_ortho_proj_and_view_matrix(ui_camera);
		
		pb.proj = proj;
		pb.view = view;
		
		pb.viewport = rectF32(0, 0, win_size.x, win_size.y);
		
		scissor := rectF32(0, 0, win_size.x, win_size.y);
		{
			params := push_batch_group_sprite_params(*pb);
			params.proj = ui_proj;
			params.view = ui_view;
			params.scissor = scissor;
		}
		
		font_begin();
		
		text_pos := Vector2.{600, 800};
		
		pos := text_pos;
		pos.y -= 32;
		size := Vector2.{670, 80};
		
		color := COLOR_RED;
		
		x,y := get_mouse_pointer_position(the_window, false);
		
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
			
			start := camera.position;
			//end := start + 1000 * ray_wor;
			
			raycast_last_frame = raycast;
			raycast = .{start, ray_wor};
		}
		
		if active_entity && current_app_mode == .Editor
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
				
				push_quad(*pb, gizmo_pos, gizmo_size, gizmo_rot, gizmo_color, get_white_square());
				
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
		
		begin_widgets(.{xx x,xx y});
		update_asset_viewer_window(*asset_viewer_window, delta, *pb);
		
		/*
		test_root := widget_test4();
		test_root.parent = *nil_widget;
		
		widget_layout_and_clip(test_root);
		draw_widgets(*pb, test_root);
			*/
		
		end_widgets();
		
		if is_key_pressed(.TAB)
		{
			current_app_mode += 1;
			current_app_mode = current_app_mode % .Count;
			toggle_cursor(xx control_camera);
			control_camera = !control_camera;
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
		for *e : entity_state.entities
		{
			model := translate(Matrix4_Identity, e.pos);
			model = scale(model, e.size);
			
			this_frame_hot : bool;
			
			aabb_rec(e, *pb, e.node_asset_hash, model, *this_frame_hot);
		}
		
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
control_camera : bool;