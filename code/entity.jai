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

set_entity_name :: (e : *Entity, name : string)
{
	// names are u8
	// Will this be annoying once I have other languages?
	// Probably but its ok for now. I can't even render utf 32 text rn.
	memcpy(e.short_name_memory.data, name.data, name.count);
	e.short_name.count = name.count;
}