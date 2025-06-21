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
	animation_hash : u128;
	mesh_asset_hash : u128;
	
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
	
	ascent : float;
	cow : *Entity;
	cow2 : *Entity;
	butterfly : *Entity;
	
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
	entities.count += 1;
	return out;
}

update_game :: (using game : *Game, pb : *R_Push_Buffer, delta : float, counter : float)
{
	if !initialized
	{
		initialized = true;
		arena = arena_init();
		
		//yk_mesh = gltf_loadMesh(arena, "yk/yk.glb");
		//test_mesh = gltf_loadMesh(arena, "sponza/Sponza.gltf");
		gltf_loadMesh(arena, "downtown.glb");
		gltf_loadMesh(arena, "watermelon_stall.glb");
		//gltf_loadMesh(arena, "simple_skin.gltf");
		gltf_loadMesh(arena, "butterfly.glb");
		//gltf_loadMesh(arena, "aos/aos.glb");
		//gltf_loadMesh(arena, "girafe.glb");
		gltf_loadMesh(arena, "cow.glb");
		camera.position = .{0, 0, 3};
		camera.control = true;
		toggle_cursor(0);
		
		entity_store_init(game);
		
		{
			cow = entity_alloc(game);
			cow.animation_hash = hash_string("cow.walk");
			cow.mesh_asset_hash = hash_string("cow");
			cow.flags |= .Animated;
		}
		
		{
			cow2 = entity_alloc(game);
			cow2.animation_hash = hash_string("cow.jump");
			cow2.mesh_asset_hash = hash_string("cow");
			cow2.pos = .{-3, 0, 0};
			cow2.flags |= .Animated;
		}
		
		{
			butterfly = entity_alloc(game);
			butterfly.animation_hash = hash_string("butterfly.fly");
			butterfly.mesh_asset_hash = hash_string("butterfly");
			butterfly.flags |= .Animated;
		}
		
		{
			watermelon_stall := entity_alloc(game);
			watermelon_stall.mesh_asset_hash = hash_string("watermelon_stall");
			watermelon_stall.pos = .{0, 0, -25};
		}
		
		font_state_init();
		
		jeff : int;
	}
	
	win_size := get_window_size(the_window);
	
	update_flying_camera(*camera, delta, win_size);
	update_2d_camera(*ui_camera, delta, win_size);
	proj, view := get_perspective_proj_and_view_matrix(camera);
	ui_proj, ui_view := get_ortho_proj_and_view_matrix(ui_camera);
	
	pb.proj = proj;
	pb.view = view;
	
	pb.ui_proj = ui_proj;
	pb.ui_view = ui_view;
	
	pb.viewport = win_size;
	
	font_begin();
	
	text_pos := Vector2.{600, 800};
	
	pos := text_pos;
	pos.y -= 32;
	size := Vector2.{670, 80};
	
	color := COLOR_RED;
	x,y := get_mouse_pointer_position(the_window, false);
	
	//print("% %\n", x, y);
	
	if x > xx (pos.x) && x < xx (pos.x + size.x)
	{
		if y > xx (pos.y) && y < xx (pos.y + size.y)
		{
			color = COLOR_GREEN;
			
			pb.hacker_draw = true;
		}
	}
	
	push_ui_quad(pb, pos, size, 0, COLOR_BLACK, get_white_square());
	//push_3d_text(pb, "please enjoy each triangle equally", .{}, .{}, .Delius, 32, COLOR_WHITE);
	push_ui_text(pb, "please enjoy each triangle equally", text_pos, .Delius, 32, COLOR_WHITE);
	
	game.cow.pos.z -= delta;
	
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
		push_mesh_asset(pb, translate(Matrix4_Identity, e.pos), e.mesh_asset_hash, color, e.joints, e.an_batch);
	}
	
	if is_key_down(xx #char "C")
	{
		active_entity = null;
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
		
		start := camera.position;
		//end := start + 1000 * ray_wor;
		
		raycast_last_frame = raycast;
		raycast = .{start, ray_wor};
	}
	
	if active_entity
	{
		push_ui_text(pb, tprint("%", active_entity.pos), .{0,32}, .Delius, 32, COLOR_WHITE);
		
		gizmo_size : Vector2 = .{0.5, 2};
		gizmo_delta := (gizmo_size.x + gizmo_size.y) / 2.;
		
		if is_grabbing && !is_key_down(.MOUSE_BUTTON_LEFT)
		{
			is_grabbing = false;
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
				
				active_entity.pos += axis * movement * delta * 100;
				
				
				//active_entity.pos.component[it] += hit_pos.component[it] - hit_pos_last.component[it];
			}
		}
	}
	
	// draw aabbs
	for *e : game.entities
	{
		meshes := meshes_from_hash(e.mesh_asset_hash);
		
		model := translate(Matrix4_Identity, e.pos);
		
		this_frame_hot : bool;
		
		for m : meshes
		{
			using m.aabb;
			
			aabb : AABB;
			aabb.min = (model * m.xform * .{m.aabb.min.x, m.aabb.min.y, m.aabb.min.z, 1}).xyz;
			aabb.max = (model * m.xform * .{m.aabb.max.x, m.aabb.max.y, m.aabb.max.z, 1}).xyz;
			
			_, hit := ray_aabb_intersection(raycast, aabb);
			
			color := COLOR_WHITE;
			
			if hit
			{
				color = COLOR_RED;
				hot_entity = e;
				this_frame_hot = true;
				
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
					<< it = (model * m.xform * .{it.x, it.y, it.z, 1}).xyz;
				}
				push_debug_line(pb, edge[0], edge[1], color);
			}
		}
		
		if !this_frame_hot
		{
			hot_entity = null;
		}
		
	}
}

hot_entity : *Entity;
active_entity : *Entity;
is_grabbing : bool;
grab_index : int = -1;
raycast_last_frame : Ray;
raycast : Ray;