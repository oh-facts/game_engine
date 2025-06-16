Entity :: struct
{
	kf_index : [256]Key_Frame_Index;
	counter : float;
	pos : Vector3;
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
		
		cow = entity_alloc(game);
		cow2 = entity_alloc(game);
		butterfly = entity_alloc(game);
		
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
	
	push_text :: (pb : *R_Push_Buffer, text : string, pos : Vector2, font_kind : Font_Kind, font_size : int, color : Vector4)
	{
		max_height : float;
		
		/*
		{
			x := pos.x;
			y := pos.y;
			
			for text
			{
				glyph := glyph_from_key(.{it, font_kind, font_size});
				
				using glyph;
				baseline := ascent;
				
				size := tex_size_from_handle(tex);
				
				max_height = max(max_height, size.y);
				x += advance_x;
			}
		}
		*/
		
		{
			x := pos.x;
			y := pos.y;
			
			for text
			{
				glyph := glyph_from_key(.{it, font_kind, font_size});
				
				using glyph;
				size := tex_size_from_handle(tex);
				
				pos_y := offset_y - size.y / 2;
				
				dp := Vector2.{x + size.x / 2 + offset_x, y - pos_y};
				push_sprite(pb, dp, size, 0, COLOR_WHITE, tex);
				
				x += advance_x;
			}
		}
		
	}
	
	text :[]string= .["boyohboy", "erere", "re"];
	t := text[(cast(int)counter) % 3];
	
	font_begin();
	
	push_sprite(pb, .{0, 0}, .{128, 128}, 0, COLOR_RED, get_white_square());
	push_text(pb, "hi", .{0, 6}, .Delius, 6, COLOR_WHITE);
	push_text(pb, t, .{0, 32}, .Delius, 32, COLOR_WHITE);
	
	// counter * PI / 180. * 45;
	/*
	for cps
	{
		using game.glyph_metrics[it_index];
		
		baseline := game.ascent >> 6;
		
		size := tex_size_from_handle(game.glyph_tex[it_index]);
		
		pos_y := baseline + offset_y - size.y / 2;
		
		push_sprite(pb, .{x + size.x / 2 + (offset_x), xx pos_y}, size, 0, COLOR_WHITE, game.glyph_tex[it_index]);
		
		x += advance_x;
	}
	*/
	
	anim, jaunt, asset := animation_data_from_key("cow.glb.walk");
	
	if is_key_pressed(.SPACEBAR) || game.cow.counter >= asset.length
	{
		for *e : game.entities
		{
			for i : 0 .. 255
			{
				e.kf_index[i].pos = 0;
				e.kf_index[i].rot = 0;
				e.counter = 0;
			}
		}
	}
	
	for *game.entities
	{
		it.counter += delta;
	}
	
	game.cow.pos.z -= delta;
	
	{
		an, an_batch := push_animation(pb, "cow.glb.walk", game.cow.counter, game.cow.kf_index);
		push_mesh_asset(pb, translate(Matrix4_Identity, game.cow.pos), "cow.glb", an, an_batch);
	}
	
	{
		an, an_batch := push_animation(pb, "cow.glb.jump", game.cow2.counter, game.cow2.kf_index);
		push_mesh_asset(pb, translate(Matrix4_Identity, .{-3, 0, 0}), "cow.glb", an, an_batch);
	}
	
	{
		an, an_batch := push_animation(pb, "butterfly.glb.fly", game.butterfly.counter, game.butterfly.kf_index);
		push_mesh_asset(pb, Matrix4_Identity, "butterfly.glb", an, an_batch);
	}
	
	{
		push_mesh_asset(pb, Matrix4_Identity, "downtown.glb");
		push_mesh_asset(pb, translate(Matrix4_Identity, .{0, 0, -25}), "watermelon_stall.glb");
	}
}