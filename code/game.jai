
Entity :: struct
{
	kf_index : [256]Key_Frame_Index;
	counter : float;
	pos : Vector3;
}

Glyph_Metrics :: struct
{
	advance_x : float;
	advance_y : float;
	offset_x : float;
	offset_y : float;
}

Game :: struct
{
	initialized : bool;
	arena : *Arena;
	
	camera : Camera;
	
	ui_camera : Camera;
	
	glyph_metrics : [cps.count]Glyph_Metrics;
	glyph_tex : [cps.count]Handle;
	
	ascent : int;
	
	cow : *Entity;
	cow2 : *Entity;
	butterfly : *Entity;
	
	entities : []Entity;
}

//cps :: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ{}";
cps :: "Summerg";

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
		
		{
			font_path := tprint("%/delius.ttf", fonts_folder);
			
			font_data := read_entire_file(font_path);
			
			library : FT_Library;
			FT_Init_FreeType(*library);
			
			face : FT_Face;
			FT_New_Memory_Face(library, font_data.data, xx font_data.count, 0, *face);
			game.ascent = xx face.ascender;
			
			FT_Set_Char_Size(face, 0, 64 * 64, 0, 96);
			
			for cps
			{
				cp := it;
				
				ch, count, _ := character_utf8_to_utf32(*cp, 1);
				
				index := FT_Get_Char_Index(face, it);
				FT_Load_Glyph(face, index, FT_LOAD_DEFAULT | FT_LOAD_RENDER);
				
				{
					using game.glyph_metrics[it_index];
					advance_x = xx face.glyph.advance.x >> 6;
					advance_y = xx face.glyph.advance.y >> 6;
					offset_x = xx face.glyph.bitmap_left;
					offset_y = xx face.glyph.bitmap_top;
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
				
				glyph_tex[it_index] = r_image_create(xx width, xx height, 4, buffer, .Linear, .Linear, .Clamp_To_Edge);
				
				jeff : int;
			}
			
		}
		
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
	
	x := -400.;
	y : float;
	
	// counter * PI / 180. * 45;
	
	for cps
	{
		using game.glyph_metrics[it_index];
		
		baseline := game.ascent >> 6;
		
		size := tex_size_from_handle(game.glyph_tex[it_index]);
		
		pos_y := baseline + offset_y - size.y / 2;
		
		push_sprite(pb, .{x + size.x / 2 + (offset_x), xx pos_y}, size, 0, COLOR_WHITE, game.glyph_tex[it_index]);
		
		x += advance_x;
	}
	
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