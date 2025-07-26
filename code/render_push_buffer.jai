// TODO(mizu): make push mesh and push animation not use asset hashes
// this file only pushes stuff to the push buffer
// render_asset would handle higher level stuff / fetch meshes and use this file as base

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

// I can lego brick batch group and batch list

Batch_List :: struct
{
	first : *Batch;
	last  : *Batch;
	next : *Batch_List;
	
	count : u32;
	
	params : *Batch_List_Params;
};

Batch_Group :: struct
{
	first : *Batch_List;
	last  : *Batch_List;
	count : u32;
	
	params_stack : *Batch_List_Params;
}

Batch_List_Params :: struct
{
	next : *Batch_List_Params;
	proj : Matrix4;
	view : Matrix4;
	scissor : RectF32;
}

nil_batch_list_params : Batch_List_Params;

push_batch_group_sprite_params :: (pb : *R_Push_Buffer) -> *Batch_List_Params
{
	out : *Batch_List_Params;
	out = tpush_struct(Batch_List_Params);
	
	//, proj : Matrix4, view : Matrix4, scissor : RectF32
	
	out.proj = pb.sprite_lists.params_stack.proj;
	out.view = pb.sprite_lists.params_stack.view;
	out.scissor = pb.sprite_lists.params_stack.scissor;
	
	// push to stack
	out.next = pb.sprite_lists.params_stack;
	pb.sprite_lists.params_stack = out;
	
	return out;
}

pop_batch_group_sprite_params :: (pb : *R_Push_Buffer)
{
	pb.sprite_lists.params_stack = pb.sprite_lists.params_stack.next;
}

R_Flags :: enum_flags u32
{
	Animated;
}

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
	sprite_lists : Batch_Group;
	quad_lists : Batch_Group;
	quad_lists_no_depth : Batch_Group;
	
	mesh_batches : Batch_List;
	
	skinning_xforms : Batch_List;
	debug_lines : Batch_List;
	debug_vertices : Batch_List;
	
	viewport : RectF32;
	proj : Matrix4;
	view : Matrix4;
	proj_view : Matrix4;
	light_proj_view : Matrix4;
	hacker_draw : bool;
	
	counter : f32;
}

begin_render :: () -> R_Push_Buffer
{
	out : R_Push_Buffer;
	out.sprite_lists.params_stack = *nil_batch_list_params;
	out.quad_lists.params_stack = *nil_batch_list_params;
	return out;
}

end_render :: (pb : *R_Push_Buffer)
{
	
}

push_batch :: (list : *Batch_List, push_size : s64, cap : s64) -> *u8
{
	profile_scope("push batch");
	
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

push_batch_list :: (group : *Batch_Group) -> *Batch_List
{
	profile_scope("push batch list");
	
	list := group.last;
	
	// is this correct?
	// think deeply
	// if you have different params, then push a new group
	// sounds correct
	// But I usually use something like a gen value
	if !list || list.params != group.params_stack
	{
		list = tzpush_struct(Batch_List);
		list.params = group.params_stack;
		
		if !group.last
		{
			group.first = list;
			group.last = list;
		}
		else
		{
			group.last.next = list;
			group.last = list;
		}
		
		group.count += 1;
	}
	
	return list;
}

push_ui_quad :: inline (pb : *R_Push_Buffer, pos : Vector2, size : Vector2, rot : float, color : Vector4, tex_id : Handle)
{
	push_quad_impl(*pb.sprite_lists, .{pos.x + size.x / 2, pos.y + size.y / 2, 0}, size, .{0, 0, rot}, color, tex_id);
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
			glyph := glyph_from_key(it, font_kind, font_size);
			
			using glyph;
			
			if tex.U64[0]
			{
				size := tex_size_from_handle(tex);
				
				pos_y := offset_y;
				
				dp := Vector2.{x + offset_x, y - pos_y};
				push_ui_quad(pb, dp, .{size.x, size.y}, 0, color, tex);
			}
			
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
		glyph := glyph_from_key(it, font_kind, font_size);
		
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
	push_quad_impl(*pb.quad_lists, pos, size, rot, color, tex_id);
}

push_quad_no_depth :: inline (pb : *R_Push_Buffer, pos : Vector3, size : Vector2, rot : Vector3, color : Vector4, tex_id : Handle)
{
	push_quad_impl(*pb.quad_lists_no_depth, pos, size, rot, color, tex_id);
}

push_quad_impl :: (group : *Batch_Group, pos : Vector3, size : Vector2, rot : Vector3, color : Vector4, tex_id : Handle)
{
	profile_scope("push quad impl");
	
	batches := push_batch_list(group);
	
	sprite :*R_Sprite = xx push_batch(batches, size_of(R_Sprite), xx MB(1));
	
	
	model := Matrix4_Identity;
	
	//if false 
	{
		profile_scope("math thing");
		
		//model = translate(model, .{pos.x + size.x / 2, pos.y + size.y / 2, 0});
		model = translate(model, pos);
		
		roll : Quaternion;
		set_from_axis_and_angle (*roll, 0, 0, -1, rot.z);
		pitch : Quaternion;
		set_from_axis_and_angle (*pitch, -1, 0, 0, rot.x);
		yaw : Quaternion;
		set_from_axis_and_angle (*yaw, 0, -1, 0, rot.y);
		rotation := roll * yaw * pitch;
		
		model = rotate(model, rotation);
		
		model = scale(model, .{size.x, size.y, 0});
	}
	
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