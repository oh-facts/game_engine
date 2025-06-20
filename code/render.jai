// NOTE(mizu):
// U32 : w, h
// U64 : ptr, tex_id

Vertex :: struct 
{
	pos : Vector3;
	uv_x : float;
	normal : Vector3;
	uv_y : float;
	color : Vector4;
	tangent : Vector3;
	pad : float;
	joints : [4]u32;
	weights : Vector4;
};

Debug_Vertex :: struct
{
	pos : Vector4;
	color : Vector4;
}

Tex_Param :: enum 
{
	Nearest;
	Linear;
	Nearest_Mipmap_Nearest;
	Linear_Mipmap_Nearest;
	Nearest_Mipmap_Linear;
	Linear_Mipmap_Linear;
	Clamp_To_Edge;
	Repeat;
}

Buffer_Hint :: enum
{
	Static_Draw;
	Dynamic_Draw;
}

R_Sprite :: struct 
{
	model : Matrix4;
	color : Vector4;
	tex_id : u64;
	pad : u64;
};

Batch :: struct 
{
	base : *u8;
	count : u32;
	size : s64;
	cap : s64;
	next : *Batch;
};

Batch_List :: struct 
{
	first : *Batch;
	last : *Batch;
	count : u32;
};

R_Flags :: enum_flags u32
{
	Animated;
}

// What I am going to do is this
// every mesh holds the joints pointer
// but it is allocated and calculated only
// per model

R_Mesh :: struct
{
	start : u32;
	count : u32;
	
	xform : Matrix4;
	
	vertex_buffer : u32;
	index_buffer : u32;
	
	color : Vector4;
	color_map : u64;
	
	flags : R_Flags;
	
	base_skinning_xform : *Matrix4;
	skinning_xform_batch : *Batch;
}

R_Push_Buffer :: struct 
{
	sprite_batches : Batch_List;
	quad_batches : Batch_List;
	mesh_batches : Batch_List;
	skinning_xforms : Batch_List;
	debug_lines : Batch_List;
	debug_vertices : Batch_List;
	
	proj : Matrix4;
	view : Matrix4;
	ui_proj : Matrix4;
	ui_view : Matrix4;
	viewport : Vector2;
	
	hacker_draw : bool;
}

push_batch :: (list : *Batch_List, push_size : s64, cap : s64) -> *u8 
{
	batch := list.last;
	
	if !batch || (batch.cap < xx (xx batch.size + push_size))
	{
		batch = tzpush_struct(Batch);
		
		if !list.first
		{
			list.last = batch;
			list.first = batch;
		}
		else
		{
			list.last.next = batch;
			list.last = batch;
		}
		
		batch.cap = cap;
		batch.base = tpush_array(u8, xx cap);
		list.count += 1;
	}
	
	out := batch.base + batch.size;
	
	batch.size += push_size;
	batch.count += 1;
	
	return out;
}

push_ui_quad :: inline (pb : *R_Push_Buffer, pos : Vector2, size : Vector2, rot : float, color : Vector4, tex_id : Handle)
{
	push_quad_impl(*pb.sprite_batches, .{pos.x + size.x / 2, pos.y + size.y / 2, 0}, size, .{0, 0, rot}, color, tex_id);
}

push_ui_text :: (pb : *R_Push_Buffer, text : string, pos : Vector2, font_kind : Font_Kind, font_size : int, color : Vector4)
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
			
			pos_y := offset_y;
			
			dp := Vector2.{x + offset_x, y - pos_y};
			push_ui_quad(pb, dp, .{size.x, size.y}, 0, color, tex);
			
			x += advance_x;
		}
	}
}

push_3d_text :: (pb : *R_Push_Buffer, text : string, pos : Vector3, rot : Vector3, font_kind : Font_Kind, font_size : int, color : Vector4)
{
	x := pos.x;
	y := pos.y;
	
	for text
	{
		glyph := glyph_from_key(.{it, font_kind, font_size});
		
		using glyph;
		size := tex_size_from_handle(tex);
		size.y = -size.y;
		pos_y := offset_y;
		
		dp := Vector3.{x + offset_x + size.x / 2, y + pos_y + size.y / 2, pos.z};
		push_quad(pb, dp, .{size.x, size.y}, rot, color, tex);
		x += advance_x;
	}
}

push_quad :: inline (pb : *R_Push_Buffer, pos : Vector3, size : Vector2, rot : Vector3, color : Vector4, tex_id : Handle)
{
	push_quad_impl(*pb.quad_batches, pos, size, rot, color, tex_id);
}

push_quad_impl :: (batches : *Batch_List, pos : Vector3, size : Vector2, rot : Vector3, color : Vector4, tex_id : Handle)
{
	sprite :*R_Sprite = xx push_batch(batches, size_of(R_Sprite), xx MB(1));
	
	model := Matrix4_Identity;
	
	//model = translate(model, .{pos.x + size.x / 2, pos.y + size.y / 2, 0});
	model = translate(model, pos);
	
	roll : Quaternion;
	set_from_axis_and_angle (*roll, 0, 0, -1, rot.z);
	pitch : Quaternion;
	set_from_axis_and_angle (*roll, -1, 0, 0, rot.x);
	yaw : Quaternion;
	set_from_axis_and_angle (*roll, 0, -1, 0, rot.y);
	rotation := roll * yaw * pitch;
	
	model = rotate(model, rotation);
	
	model = scale(model, .{size.x, size.y, 0});
	
	sprite.model = model;
	sprite.color = color;
	sprite.tex_id = tex_id_from_handle(tex_id);
}

push_animation :: (pb : *R_Push_Buffer, anim_hash : u128, counter : float, kf_index : []Key_Frame_Index) -> *Matrix4, *Batch
{
	anim, jaunt := animation_data_from_hash(anim_hash);
	
	jaunt_count := jaunt.count;
	
	xforms : *Matrix4 = xx push_batch(*pb.skinning_xforms, size_of(Matrix4) * jaunt_count, xx MB(1));
	
	for 0 .. jaunt_count - 1
	{
		bind_pose := matrix_from_transform(jaunt[it].bind_pose);
		
		xforms[it] = bind_pose;
	}
	
	for 0 .. jaunt_count - 1
	{
		if anim[it].pos.count
		{
			while (kf_index[it].pos + 1 < anim[it].pos.count) && (anim[it].pos[kf_index[it].pos + 1].timestamp <= counter)
			{
				kf_index[it].pos += 1;
			}
			
			frame := kf_index[it].pos;
			
			xforms[it] = translate(Matrix4_Identity, anim[it].pos[frame].v.xyz);
			
		}
		
		if anim[it].rot.count
		{
			while (kf_index[it].rot + 1 < anim[it].rot.count) && (anim[it].rot[kf_index[it].rot + 1].timestamp <= counter)
			{
				kf_index[it].rot += 1;
			}
			
			frame := kf_index[it].rot;
			
			xforms[it] = rotate(xforms[it], cast,force(Quaternion) anim[it].rot[frame].v);
		}
		
		if anim[it].scale.count
		{
			while (kf_index[it].scale + 1 < anim[it].scale.count) && (anim[it].scale[kf_index[it].scale + 1].timestamp <= counter)
			{
				kf_index[it].scale += 1;
			}
			
			frame := kf_index[it].scale;
			
			xforms[it] = scale(xforms[it], anim[it].scale[frame].v.xyz);
		}
		
	}
	
	for 0 .. jaunt_count - 1
	{
		
		if jaunt[it].parent_index != -1
		{
			xforms[it] = xforms[jaunt[it].parent_index] * xforms[it];
			//print("e");
		}
		
		jeff : int;
	}
	
	for 0 .. jaunt_count - 1
	{
		xforms[it] *= jaunt[it].offset;
		
		jeff : int;
	}
	
	return xforms, pb.skinning_xforms.last;
}

push_debug_line :: (pb : *R_Push_Buffer, start : Vector3, end : Vector3, color : Vector4)
{
	vertices : *Debug_Vertex = xx push_batch(*pb.debug_lines, size_of(Debug_Vertex) * 2, xx MB(1));
	
	vertices[0].pos.xyz = start;
	vertices[0].color = color;
	
	vertices[1].pos.xyz = end;
	vertices[1].color = color;
}

push_debug_vertex :: (pb : *R_Push_Buffer, pos : Vector3, color : Vector4)
{
	vertices : *Debug_Vertex = xx push_batch(*pb.debug_vertices, size_of(Debug_Vertex), xx MB(1));
	
	vertices[0].pos.xyz = pos;
	vertices[0].color = color;
}

push_mesh_asset :: (pb : *R_Push_Buffer, model : Matrix4, hash : u128, tint := COLOR_WHITE, joints : *Matrix4 = xx 0, an_batch : *Batch = xx 0)
{
	asset := meshes_from_hash(hash);
	
	for 0 .. asset.count - 1
	{
		a_mesh := asset[it];
		
		for 0 .. a_mesh.num_primitives - 1
		{
			r_mesh :*R_Mesh = xx push_batch(*pb.mesh_batches, size_of(R_Mesh), xx MB(1));
			a_prim := a_mesh.primitives + it;
			
			r_mesh.start = a_prim.start;
			r_mesh.count = a_prim.count;
			
			r_mesh.xform = model * a_mesh.xform;
			r_mesh.vertex_buffer = a_mesh.vertex_buffer;
			r_mesh.index_buffer = a_mesh.index_buffer;
			
			color, color_map := material_data_from_hash(a_prim.material_hash);
			
			if color == .{}
			{
				r_mesh.color = .{1, 1, 1, 1};
			}
			else
			{
				r_mesh.color = color;
			}
			
			r_mesh.color *= tint;
			
			if color_map.U64[0]
			{
				r_mesh.color_map = tex_id_from_handle(color_map);
			}
			else
			{
				r_mesh.color_map = tex_id_from_handle(get_white_square());
			}
			
			if joints
			{
				r_mesh.flags |= .Animated;
				//r_mesh.skinning_xform_batch = pb.skinning_xforms.last;
				r_mesh.base_skinning_xform = joints;
				r_mesh.skinning_xform_batch = an_batch;
			}
			
		}
	}
}