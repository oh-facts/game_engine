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

Game :: struct
{
	initialized : bool;
	arena : *Arena;
	
	camera : Camera;
	ui_camera : Camera;
	
	entities : []Entity;
}

//cps :: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ{}";

entity_store_init :: (using game : *Game)
{
	entities.data = push_array(arena, Entity, 100);
}

entity_alloc :: (using game : *Game) -> *Entity
{
	out := entities.data + entities.count;
	out.size = .{1,1,1};
	entities.count += 1;
	return out;
}

update_game :: (using game : *Game, pb : *R_Push_Buffer, delta : float, counter : float)
{
	if !initialized
	{
		initialized = true;
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
		
		entity_store_init(game);
		
		//watermelon_stall.root
		
		font_state_init();
		
		jeff : int;
		
		widget_init();
	}
	
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
		params := push_batch_group_sprite_params(pb);
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
			
			push_quad(pb, gizmo_pos, gizmo_size, gizmo_rot, gizmo_color, get_white_square());
			
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
	
	nil_widget : Widget;
	entity_widget_root := *nil_widget;
	placer_widget_root := *nil_widget;
	
	new_context := context;
	push_context new_context
	{
		{
			col();
			entity_widget_root = _start;
			entity_widget_root.fixed_pos = .{60, 60};
			
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
		
		//if false 
		{
			col();
			placer_widget_root = _start;
			placer_widget_root.fixed_pos = .{600, 300};
			
			view_offset : Vector2;
			view_offset.y += wheel_delta;
			
			placer_widget_root.view_offset = view_offset;
			placer_widget_root.clip_size = .{300, 300};
			placer_widget_root.flags |= .Clip;
			
			asset_index : int;
			for slot : asset_store.meshes
			{
				asset := slot.first;
				while asset
				{
					if fixed_label(tprint("%", asset.key), asset_index)
					{
						active_asset_hash = asset.hash;
					}
					asset_index += 1;
					asset = asset.hash_next;
				}
			}
			
			fixed_label(tprint("%", placer_widget_root.final_size));
			
			if active_asset_hash.U64[0]
			{
				push_mesh(pb, Matrix4_Identity, active_asset_hash);
			}
		}
		
		if false 
		{
			col();
			placer_widget_root = _start;
			placer_widget_root.fixed_pos = .{600, 60};
			
			for slot : asset_store.nodes
			{
				asset := slot.first;
				while asset
				{
					if !asset.parent_key.count
					{
						if fixed_label(tprint("%", asset.key), it_index)
						{
							active_asset_hash = asset.hash;
						}
					}
					
					asset = asset.hash_next;
				}
			}
			fixed_label(tprint("%", placer_widget_root.final_size));
		}
		
		if active_asset_hash.U64[0]
		{
			push_mesh_node(pb, Matrix4_Identity, active_asset_hash);
		}
	}
	
	/*
		test_root := widget_test();
		widget_layout(test_root);
		draw_widgets(pb, test_root);
		*/
	
	entity_widget_root.parent = *nil_widget;
	placer_widget_root.parent = *nil_widget;
	
	widget_layout_and_clip(entity_widget_root);
	widget_layout_and_clip(placer_widget_root);
	
	draw_widgets(pb, entity_widget_root);
	draw_widgets(pb, placer_widget_root);
	
	end_widgets();
	
	if is_key_pressed(.TAB)
	{
		current_app_mode += 1;
		current_app_mode = current_app_mode % .Count;
		toggle_cursor(xx control_camera);
		control_camera = !control_camera;
	}
	
	// animate entities
	for *e : game.entities
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
			
			joints, an_batch := push_animation(pb, e.animation_hash, e.counter, e.kf_index);
			e.joints = joints;
			e.an_batch = an_batch;
		}
	}
	
	// draw entities
	for e : game.entities
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
		
		push_mesh_node(pb, model, e.node_asset_hash, color, e.joints, e.an_batch);
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
			aabb.min = (model * node.xform * .{m.aabb.min.x, m.aabb.min.y, m.aabb.min.z, 1}).xyz;
			aabb.max = (model * node.xform * .{m.aabb.max.x, m.aabb.max.y, m.aabb.max.z, 1}).xyz;
			
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
					<< it = (model * node.xform * .{it.x, it.y, it.z, 1}).xyz;
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
	for *e : game.entities
	{
		model := translate(Matrix4_Identity, e.pos);
		model = scale(model, e.size);
		
		this_frame_hot : bool;
		
		aabb_rec(e, pb, e.node_asset_hash, model, *this_frame_hot);
	}
	
	pop_batch_group_sprite_params(pb);
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

active_asset_hash : u128;