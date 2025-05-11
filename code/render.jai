// NOTE(mizu):
// U32 : w, h
// U64 : ptr, tex_id

Tex_Params :: enum 
{
	Linear;
	Nearest;
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

R_Push_Buffer :: struct 
{
	sprite_batches : Batch_List;
	proj : Matrix4;
	view : Matrix4;
	viewport : Vector2;
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

push_sprite :: (pb : *R_Push_Buffer, pos : Vector2, size : Vector2, rot : float, color : Vector4, tex_id : Handle)
{
	sprite :*R_Sprite = xx push_batch(*pb.sprite_batches, size_of(R_Sprite), xx MB(1));
	
	model := Matrix4_Identity;
	
	model = translate(model, .{pos.x, pos.y, 0});
	
	roll : Quaternion;
	set_from_axis_and_angle (*roll, 0, 0, 1, rot);
	
	model = rotate(model, roll);
	
	model = scale(model, .{size.x, size.y, 0});
	
	sprite.model = model;
	sprite.color = color;
	sprite.tex_id = tex_id_from_handle(tex_id);
}