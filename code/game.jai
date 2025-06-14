
Entity :: struct
{
	kf_index : [256]Key_Frame_Index;
	counter : float;
	pos : Vector3;
}

Game :: struct
{
	initialized : bool;
	arena : *Arena;
	
	camera : Camera;
	
	ui_camera : Camera;
	
	glyph_tex : [cps.count]Handle;
	glyph_metrics : [cps.count]DWRITE_GLYPH_METRICS;
	font_metrics : DWRITE_FONT_METRICS;
	
	cow : *Entity;
	cow2 : *Entity;
	butterfly : *Entity;
	
	entities : []Entity;
}

cps :: string.[
							 "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
							 "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
							 "u", "v", "w", "x", "y", "z",
							 "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
							 "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
							 "U", "V", "W", "X", "Y", "Z", "{", "}"
							 ];

em_size :: 96 / 72. * 64;

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
			
			dwrite_factory : *IDWriteFactory;
			
			font_file : *IDWriteFontFile;
			font_face : *IDWriteFontFace;
			
			error := DWriteCreateFactory(.DWRITE_FACTORY_TYPE_SHARED, uid(IDWriteFactory_UUID), xx *dwrite_factory);
			
			utf16_fp, succ, fp_len := utf8_to_wide(font_path);
			error = IDWriteFactory_CreateFontFileReference(dwrite_factory, xx utf16_fp, xx 0, *font_file);
			
			error = IDWriteFactory_CreateFontFace(dwrite_factory, .DWRITE_FONT_FACE_TYPE_TRUETYPE, 1, *font_file, 0, .DWRITE_FONT_SIMULATIONS_NONE, *font_face);
			
			IDWriteFontFace_GetMetrics(font_face, *font_metrics);
			
			for cps
			{
				cp := it;
				
				ch, count, _ := character_utf8_to_utf32(cp.data, cp.count);
				
				
				glyph_index : *u16 = tpush_array(u16, count);
				error = IDWriteFontFace_GetGlyphIndicesW(font_face, *ch, xx count, glyph_index);
				
				glyph_indices : *u16 = tpush_array(u16, count * 2);
				glyph_indices[0] = 80;
				glyph_indices[1] = 72;
				
				//poo : *s32 = tpush_array(s32, count * 2);
				
				//bo : *IDWriteFontFace1;
				//bo = xx font_face;
				//error = IDWriteFontFace1_GetKerningPairAdjustments(xx font_face, xx (count * 2), glyph_indices, poo);
				
				IDWriteFontFace_GetDesignGlyphMetrics(font_face, glyph_index, 1, *glyph_metrics[it_index]);
				
				jeffy : int;
				
				glyph_run : DWRITE_GLYPH_RUN;
				{
					using glyph_run;
					fontFace = font_face;
					fontEmSize = em_size;
					glyphCount = xx count;
					glyphIndices = glyph_index;
				}
				
				analysis : *IDWriteGlyphRunAnalysis;
				
				error = IDWriteFactory_CreateGlyphRunAnalysis(dwrite_factory, *glyph_run, 1., xx 0, .DWRITE_RENDERING_MODE_CLEARTYPE_NATURAL, .DWRITE_MEASURING_MODE_NATURAL, 0., 0., *analysis);
				
				bounds : RECT;
				
				error = IDWriteGlyphRunAnalysis_GetAlphaTextureBounds(analysis, .DWRITE_TEXTURE_CLEARTYPE_3x1, *bounds);
				
				width := bounds.right - bounds.left;
				height := bounds.bottom - bounds.top;
				size := width * height * 3;
				size2 := width * height * 4;
				
				buffer :*u8= xx tzpush_array(u8, size);
				
				error = IDWriteGlyphRunAnalysis_CreateAlphaTexture(analysis, .DWRITE_TEXTURE_CLEARTYPE_3x1, *bounds, buffer, xx size);
				
				buffer2 :*u8= xx tzpush_array(u8, size2);
				
				i := 0;
				j := 0;
				
				while i != size
				{
					r,g,b : u8;
					r = buffer[i];
					g = buffer[i + 1];
					b = buffer[i + 2];
					
					buffer2[j + 0] = r;
					buffer2[j + 1] = g;
					buffer2[j + 2] = b;
					buffer2[j + 3] = r;
					
					i += 3;
					j += 4;
				}
				
				glyph_tex[it_index] = r_image_create(width, height, 4, buffer2, .Linear, .Linear, .Clamp_To_Edge);
				
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
	
	x := -1920.;
	y : float;
	
	// counter * PI / 180. * 45;
	
	for cps
	{
		using game.font_metrics;
		using game.glyph_metrics[it_index];
		
		px_size := em_size / designUnitsPerEm;
		
		baseline := ascent * px_size;
		
		size := tex_size_from_handle(game.glyph_tex[it_index]);
		
		pos_y := (baseline + (bottomSideBearing)* px_size) + size.y / 2;
		
		
		push_sprite(pb, .{x + (leftSideBearing * px_size) + size.x / 2, pos_y}, size, 0, COLOR_WHITE, game.glyph_tex[it_index]);
		
		x += advanceWidth * px_size;
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